import Foundation
import os.log

private let logger = Logger(subsystem: "com.alexislours.yours", category: "PendingGiftStore")

struct PendingGift: Codable {
    let title: String
    let note: String?
    let priceString: String?
    let urlString: String?
    let occasion: String
    let createdAt: Date
}

enum PendingGiftStore {
    private static let fileName = "pendingGifts.json"

    private static var fileURL: URL? {
        FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: SharedDefaults.suiteName
        )?.appending(path: fileName)
    }

    static func append(_ gift: PendingGift) {
        coordinated { url in
            var existing = read(from: url)
            existing.append(gift)
            write(existing, to: url)
        }
    }

    static func loadAndClearAll() -> [PendingGift] {
        guard let url = fileURL else {
            logger.error("App group container unavailable for reading pending gifts")
            return []
        }
        let coordinator = NSFileCoordinator()
        var coordinationError: NSError?
        var result: [PendingGift] = []
        coordinator.coordinate(writingItemAt: url, options: .forDeleting, error: &coordinationError) { coordURL in
            result = read(from: coordURL)
            guard !result.isEmpty else { return }
            do {
                try FileManager.default.removeItem(at: coordURL)
            } catch {
                logger.error("Failed to remove pending gifts file during loadAndClear: \(error.localizedDescription)")
                result = []
            }
        }
        if let coordinationError {
            logger.error("File coordination failed during loadAndClearAll: \(coordinationError.localizedDescription)")
        }
        return result
    }

    // MARK: - Private

    private static func read(from url: URL) -> [PendingGift] {
        guard FileManager.default.fileExists(atPath: url.path()) else { return [] }
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode([PendingGift].self, from: data)
        } catch {
            logger.error("Failed to read pending gifts: \(error.localizedDescription)")
            return []
        }
    }

    private static func write(_ gifts: [PendingGift], to url: URL) {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(gifts)
            try data.write(to: url, options: .atomic)
        } catch {
            logger.error("Failed to write pending gifts: \(error.localizedDescription)")
        }
    }

    private static func coordinated(_ body: (URL) -> Void) {
        guard let url = fileURL else {
            logger.error("App group container unavailable for writing pending gift")
            return
        }
        let coordinator = NSFileCoordinator()
        var coordinationError: NSError?
        coordinator.coordinate(writingItemAt: url, error: &coordinationError) { coordURL in
            body(coordURL)
        }
        if let coordinationError {
            logger.error("File coordination failed during write: \(coordinationError.localizedDescription)")
        }
    }
}
