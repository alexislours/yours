import Foundation
import SwiftData

@Model
final class TheirPeopleItem {
    var name: String = ""
    var note: String?
    var predefinedCategory: TheirPeoplePredefinedCategory = TheirPeoplePredefinedCategory.other
    var customCategory: TheirPeopleCategory?
    var createdAt: Date = Date.now
    var updatedAt: Date = Date.now
    var person: Person?

    init(
        name: String,
        note: String? = nil,
        predefinedCategory: TheirPeoplePredefinedCategory = .other,
        customCategory: TheirPeopleCategory? = nil,
        person: Person
    ) {
        self.name = name
        self.note = note
        self.predefinedCategory = predefinedCategory
        self.customCategory = customCategory
        createdAt = .now
        updatedAt = .now
        self.person = person
    }
}

// MARK: - Predefined Categories

enum TheirPeoplePredefinedCategory: String, CaseIterable, Codable, PredefinedCategoryType {
    case mom
    case dad
    case sibling
    case grandparent
    case child
    case extendedFamily
    case friend
    case coworker
    case other

    nonisolated var displayName: String {
        switch self {
        case .mom: "Mom"
        case .dad: "Dad"
        case .sibling: "Sibling"
        case .grandparent: "Grandparent"
        case .child: "Child"
        case .extendedFamily: "Extended Family"
        case .friend: "Friend"
        case .coworker: "Coworker"
        case .other: "Other"
        }
    }

    nonisolated var icon: String {
        switch self {
        case .mom: "figure.stand"
        case .dad: "figure.stand"
        case .sibling: "person.2.fill"
        case .grandparent: "person.fill"
        case .child: "figure.child"
        case .extendedFamily: "person.3.fill"
        case .friend: "face.smiling.fill"
        case .coworker: "briefcase.fill"
        case .other: "square.grid.2x2"
        }
    }

    nonisolated var colorName: String {
        switch self {
        case .mom: "terracotta"
        case .dad: "dusk"
        case .sibling: "sage"
        case .grandparent: "lavender"
        case .child: "eucalyptus"
        case .extendedFamily: "amber"
        case .friend: "rose"
        case .coworker: "slate"
        case .other: "clay"
        }
    }

    nonisolated var isFamily: Bool {
        switch self {
        case .mom, .dad, .sibling, .grandparent, .extendedFamily:
            true
        case .child, .friend, .coworker, .other:
            false
        }
    }

    nonisolated var displayOrder: Int {
        switch self {
        case .mom, .dad, .sibling, .grandparent, .extendedFamily: 0
        case .child: 1
        case .friend: 2
        case .coworker: 3
        case .other: 4
        }
    }

    nonisolated var familySortOrder: Int {
        switch self {
        case .mom: 0
        case .dad: 1
        case .sibling: 2
        case .grandparent: 3
        case .extendedFamily: 4
        default: 99
        }
    }

    static let familyIcon = "house.fill"
    static let familyColorName = "lavender"
}

// MARK: - CategorizedItem

extension TheirPeopleItem: CategorizedItem, CategorizedItemMutating {
    var resolvedPredefinedCategory: TheirPeoplePredefinedCategory {
        predefinedCategory
    }

    /// Override: groups all family members under a single "family" key.
    var categoryGroupKey: String {
        if let custom = customCategory {
            return "custom:\(custom.persistentModelID)"
        }
        if predefinedCategory.isFamily {
            return "family"
        }
        return predefinedCategory.rawValue
    }
}

extension TheirPeopleItem {
    var categoryDisplayOrder: Int? {
        if customCategory != nil { return nil }
        return predefinedCategory.displayOrder
    }

    var isInFamilyGroup: Bool {
        customCategory == nil && predefinedCategory.isFamily
    }

    var familySortOrder: Int {
        predefinedCategory.familySortOrder
    }

    var relationshipTag: String? {
        guard isInFamilyGroup else { return nil }
        return predefinedCategory.displayName
    }
}
