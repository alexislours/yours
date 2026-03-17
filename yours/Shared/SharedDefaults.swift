import Foundation

enum SharedDefaults {
    static let suiteName = "group.com.alexislours.yours"
    static let fileName = "widgetPayload.json"

    private static var containerURL: URL? {
        FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: suiteName
        )
    }

    private static var fileURL: URL? {
        containerURL?.appendingPathComponent(fileName)
    }

    /// Returns `true` if data was actually written (i.e., it differed from existing).
    @discardableResult
    static func write(_ data: Data) -> Bool {
        if var url = fileURL {
            if let existing = try? Data(contentsOf: url), existing == data {
                return false
            }
            try? data.write(to: url, options: .atomic)
            var values = URLResourceValues()
            values.isExcludedFromBackup = true
            try? url.setResourceValues(values)
            return true
        }
        let defaults = UserDefaults(suiteName: suiteName)
        if defaults?.data(forKey: "widgetPayload") == data {
            return false
        }
        defaults?.set(data, forKey: "widgetPayload")
        return true
    }

    static func read() -> Data? {
        if let url = fileURL, FileManager.default.fileExists(atPath: url.path) {
            return try? Data(contentsOf: url)
        }
        return UserDefaults(suiteName: suiteName)?.data(forKey: "widgetPayload")
    }
}
