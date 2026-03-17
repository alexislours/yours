import Foundation
import SwiftData

@Model
final class GiftIdea {
    var title: String = ""
    var note: String?
    var price: Decimal?
    var urlString: String?
    var status: GiftStatus = GiftStatus.idea
    var createdAt: Date = Date.now
    var updatedAt: Date = Date.now
    var predefinedCategory: GiftOccasion = GiftOccasion.justBecause
    var customCategory: GiftCategory?
    var linkedDate: ImportantDate?
    var person: Person?

    init(
        title: String,
        note: String? = nil,
        price: Decimal? = nil,
        urlString: String? = nil,
        status: GiftStatus = .idea,
        predefinedCategory: GiftOccasion = .justBecause,
        customCategory: GiftCategory? = nil,
        linkedDate: ImportantDate? = nil,
        person: Person
    ) {
        self.title = title
        self.note = note
        self.price = price
        self.urlString = urlString
        self.status = status
        self.predefinedCategory = predefinedCategory
        self.customCategory = customCategory
        self.linkedDate = linkedDate
        createdAt = .now
        updatedAt = .now
        self.person = person
    }
}

// MARK: - Status

enum GiftStatus: String, CaseIterable, Codable {
    case idea
    case purchased
    case given
    case archived

    nonisolated var displayName: String {
        rawValue.capitalized
    }

    nonisolated var icon: String {
        switch self {
        case .idea: "lightbulb"
        case .purchased: "bag"
        case .given: "gift"
        case .archived: "archivebox"
        }
    }

    /// Next status in the lifecycle (idea > purchased > given).
    nonisolated var next: GiftStatus? {
        switch self {
        case .idea: .purchased
        case .purchased: .given
        case .given: nil
        case .archived: nil
        }
    }
}

// MARK: - Predefined Occasions

enum GiftOccasion: String, CaseIterable, Codable, PredefinedCategoryType {
    case birthday
    case anniversary
    case holiday
    case justBecause

    nonisolated var displayName: String {
        switch self {
        case .justBecause: "Just Because"
        default: rawValue.capitalized
        }
    }

    nonisolated var icon: String {
        switch self {
        case .birthday: "birthday.cake.fill"
        case .anniversary: "heart.fill"
        case .holiday: "airplane"
        case .justBecause: "sparkles"
        }
    }

    nonisolated var colorName: String {
        switch self {
        case .birthday: "accentRose"
        case .anniversary: "accentSecondary"
        case .holiday: "caution"
        case .justBecause: "accentPrimary"
        }
    }
}

// MARK: - CategorizedItem

extension GiftIdea: CategorizedItem {
    var resolvedPredefinedCategory: GiftOccasion {
        predefinedCategory
    }
}

// MARK: - Computed Properties

extension GiftIdea {
    var formattedPrice: String? {
        guard let price else { return nil }
        return CurrencyFormatting.format(price)
    }

    var url: URL? {
        guard let urlString, !urlString.isEmpty else { return nil }
        if urlString.hasPrefix("http://") || urlString.hasPrefix("https://") {
            return URL(string: urlString)
        }
        return URL(string: "https://\(urlString)")
    }

    var domainName: String? {
        url?.host()
    }
}
