import Foundation
import SwiftData

@Model
final class LikeDislikeItem {
    var name: String = ""
    var note: String?
    var kind: Kind = Kind.like
    var predefinedCategory: LikeDislikePredefinedCategory = LikeDislikePredefinedCategory.other
    var customCategory: LikeDislikeCategory?
    var createdAt: Date = Date.now
    var updatedAt: Date = Date.now
    var person: Person?

    init(
        name: String,
        note: String? = nil,
        kind: Kind,
        predefinedCategory: LikeDislikePredefinedCategory = .other,
        customCategory: LikeDislikeCategory? = nil,
        person: Person
    ) {
        self.name = name
        self.note = note
        self.kind = kind
        self.predefinedCategory = predefinedCategory
        self.customCategory = customCategory
        createdAt = .now
        updatedAt = .now
        self.person = person
    }

    enum Kind: String, Codable {
        case like, dislike
    }
}

// MARK: - Predefined Categories

enum LikeDislikePredefinedCategory: String, CaseIterable, Codable, PredefinedCategoryType {
    case foodDrinks
    case music
    case moviesTv
    case books
    case activitiesHobbies
    case travel
    case fashionStyle
    case sports
    case animals
    case colors
    case seasons
    case peopleTraits
    case other

    nonisolated var displayName: String {
        switch self {
        case .foodDrinks: "Food & Drinks"
        case .music: "Music"
        case .moviesTv: "Movies & TV"
        case .books: "Books"
        case .activitiesHobbies: "Activities & Hobbies"
        case .travel: "Travel"
        case .fashionStyle: "Fashion & Style"
        case .sports: "Sports"
        case .animals: "Animals"
        case .colors: "Colors"
        case .seasons: "Seasons"
        case .peopleTraits: "People Traits"
        case .other: "Other"
        }
    }

    nonisolated var icon: String {
        switch self {
        case .foodDrinks: "fork.knife"
        case .music: "music.note"
        case .moviesTv: "tv"
        case .books: "book"
        case .activitiesHobbies: "figure.run"
        case .travel: "airplane"
        case .fashionStyle: "tshirt"
        case .sports: "sportscourt"
        case .animals: "pawprint"
        case .colors: "paintpalette"
        case .seasons: "leaf"
        case .peopleTraits: "person.fill"
        case .other: "square.grid.2x2"
        }
    }

    nonisolated var colorName: String {
        switch self {
        case .foodDrinks: "terracotta"
        case .music: "dusk"
        case .moviesTv: "slate"
        case .books: "amber"
        case .activitiesHobbies: "sage"
        case .travel: "eucalyptus"
        case .fashionStyle: "lavender"
        case .sports: "ochre"
        case .animals: "rose"
        case .colors: "lavender"
        case .seasons: "sage"
        case .peopleTraits: "slate"
        case .other: "clay"
        }
    }

    /// Whether this category can be hidden by the user.
    nonisolated var isHideable: Bool {
        self != .other
    }
}

// MARK: - CategorizedItem

extension LikeDislikeItem: CategorizedItem, CategorizedItemMutating {
    var resolvedPredefinedCategory: LikeDislikePredefinedCategory {
        predefinedCategory
    }
}
