import Foundation

enum GiftOccasion: String, CaseIterable, Codable, Identifiable {
    case birthday
    case anniversary
    case holiday
    case justBecause

    var id: String {
        rawValue
    }

    var displayName: String {
        switch self {
        case .birthday: String(localized: "Birthday", comment: "Gift occasion: birthday")
        case .anniversary: String(localized: "Anniversary", comment: "Gift occasion: anniversary")
        case .holiday: String(localized: "Holiday", comment: "Gift occasion: holiday")
        case .justBecause: String(localized: "Just Because", comment: "Gift occasion: just because")
        }
    }

    var icon: String {
        switch self {
        case .birthday: "birthday.cake.fill"
        case .anniversary: "heart.fill"
        case .holiday: "airplane"
        case .justBecause: "sparkles"
        }
    }

    var colorName: String {
        switch self {
        case .birthday: "accentRose"
        case .anniversary: "accentSecondary"
        case .holiday: "caution"
        case .justBecause: "accentPrimary"
        }
    }
}
