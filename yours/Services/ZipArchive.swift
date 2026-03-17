import Foundation

struct ZipEntry {
    let filename: String
    let data: Data
}

/// Minimal ZIP archive reader/writer (stored, no compression).
enum ZipArchive {
    static func isZip(_ data: Data) -> Bool {
        data.count >= 4 &&
            data[0] == 0x50 && data[1] == 0x4B &&
            data[2] == 0x03 && data[3] == 0x04
    }

    // MARK: - Create

    static func create(entries: [ZipEntry]) -> Data {
        var archive = Data()
        var centralDirectory = Data()
        var localOffsets: [UInt32] = []

        let now = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: Date())
        let hour = now.hour ?? 0
        let minute = now.minute ?? 0
        let second = now.second ?? 0
        let year = now.year ?? 2000
        let month = now.month ?? 1
        let day = now.day ?? 1
        let dosTime = UInt16((hour << 11) | (minute << 5) | (second / 2))
        let dosDate = UInt16(((year - 1980) << 9) | (month << 5) | day)

        for entry in entries {
            let nameBytes = Data(entry.filename.utf8)
            let crc = crc32(entry.data)
            let size = UInt32(entry.data.count)

            localOffsets.append(UInt32(archive.count))

            // Local file header
            archive += [0x50, 0x4B, 0x03, 0x04]
            archive.appendLE(UInt16(20))
            archive.appendLE(UInt16(0))
            archive.appendLE(UInt16(0)) // stored
            archive.appendLE(dosTime)
            archive.appendLE(dosDate)
            archive.appendLE(crc)
            archive.appendLE(size)
            archive.appendLE(size)
            archive.appendLE(UInt16(nameBytes.count))
            archive.appendLE(UInt16(0)) // no extra field
            archive += nameBytes
            archive += entry.data
        }

        let cdOffset = UInt32(archive.count)

        for (idx, entry) in entries.enumerated() {
            let nameBytes = Data(entry.filename.utf8)
            let crc = crc32(entry.data)
            let size = UInt32(entry.data.count)

            centralDirectory += [0x50, 0x4B, 0x01, 0x02]
            centralDirectory.appendLE(UInt16(20))
            centralDirectory.appendLE(UInt16(20))
            centralDirectory.appendLE(UInt16(0))
            centralDirectory.appendLE(UInt16(0)) // stored
            centralDirectory.appendLE(dosTime)
            centralDirectory.appendLE(dosDate)
            centralDirectory.appendLE(crc)
            centralDirectory.appendLE(size)
            centralDirectory.appendLE(size)
            centralDirectory.appendLE(UInt16(nameBytes.count))
            centralDirectory.appendLE(UInt16(0)) // extra
            centralDirectory.appendLE(UInt16(0)) // comment
            centralDirectory.appendLE(UInt16(0)) // disk start
            centralDirectory.appendLE(UInt16(0)) // internal attrs
            centralDirectory.appendLE(UInt32(0)) // external attrs
            centralDirectory.appendLE(localOffsets[idx])
            centralDirectory += nameBytes
        }

        archive += centralDirectory

        // End of central directory record
        archive += [0x50, 0x4B, 0x05, 0x06]
        archive.appendLE(UInt16(0))
        archive.appendLE(UInt16(0))
        archive.appendLE(UInt16(entries.count))
        archive.appendLE(UInt16(entries.count))
        archive.appendLE(UInt32(centralDirectory.count))
        archive.appendLE(cdOffset)
        archive.appendLE(UInt16(0))

        return archive
    }

    // MARK: - Extract

    static func extract(from data: Data) -> [ZipEntry] {
        var entries: [ZipEntry] = []
        var offset = 0

        while offset + 30 <= data.count {
            // Local file header signature
            guard data[offset] == 0x50, data[offset + 1] == 0x4B,
                  data[offset + 2] == 0x03, data[offset + 3] == 0x04
            else { break }

            let compression = data.readLE(UInt16.self, at: offset + 8)
            let compressedSize = Int(data.readLE(UInt32.self, at: offset + 18))
            let filenameLen = Int(data.readLE(UInt16.self, at: offset + 26))
            let extraLen = Int(data.readLE(UInt16.self, at: offset + 28))

            let nameStart = offset + 30
            let nameEnd = nameStart + filenameLen
            let dataStart = nameEnd + extraLen
            let dataEnd = dataStart + compressedSize

            guard dataEnd <= data.count else { break }

            // Only handle stored files
            if compression == 0,
               let filename = String(data: data[nameStart ..< nameEnd], encoding: .utf8) {
                entries.append(ZipEntry(filename: filename, data: Data(data[dataStart ..< dataEnd])))
            }

            offset = dataEnd
        }

        return entries
    }

    // MARK: - CRC-32

    private static let crcTable: [UInt32] = (0 ... 255).map { index -> UInt32 in
        var crc = UInt32(index)
        for _ in 0 ..< 8 {
            crc = (crc & 1) != 0 ? 0xEDB8_8320 ^ (crc >> 1) : crc >> 1
        }
        return crc
    }

    static func crc32(_ data: Data) -> UInt32 {
        data.reduce(0xFFFF_FFFF) { crc, byte in
            crcTable[Int((crc ^ UInt32(byte)) & 0xFF)] ^ (crc >> 8)
        } ^ 0xFFFF_FFFF
    }
}

// MARK: - Data helpers

private extension Data {
    mutating func appendLE(_ value: some FixedWidthInteger) {
        var val = value.littleEndian
        Swift.withUnsafeBytes(of: &val) { self += $0 }
    }
}

extension Data {
    func readLE<T: FixedWidthInteger>(_: T.Type, at offset: Int) -> T {
        var value: T = 0
        guard offset + MemoryLayout<T>.size <= count else { return value }
        _ = Swift.withUnsafeMutableBytes(of: &value) {
            copyBytes(to: $0, from: offset ..< offset + MemoryLayout<T>.size)
        }
        return T(littleEndian: value)
    }
}
