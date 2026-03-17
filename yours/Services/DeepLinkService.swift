import Foundation

enum DeepLink: String {
    case home
    case importantDates

    var url: URL {
        guard let url = URL(string: "yours://\(rawValue)") else {
            preconditionFailure("Invalid deep link URL for \(rawValue)")
        }
        return url
    }

    init?(url: URL) {
        guard url.scheme == "yours", let host = url.host() else { return nil }
        self.init(rawValue: host)
    }
}
