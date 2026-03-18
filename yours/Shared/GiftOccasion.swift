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
        case .justBecause: "Just Because"
        default: rawValue.capitalized
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
