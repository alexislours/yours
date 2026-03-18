import Foundation
import SwiftData

@Model
final class AllergyItem {
    var name: String = ""
    var note: String?
    var predefinedCategory: AllergyPredefinedCategory = AllergyPredefinedCategory.other
    var customCategory: AllergyCategory?
    var createdAt: Date = Date.now
    var updatedAt: Date = Date.now
    var person: Person?

    init(
        name: String,
        note: String? = nil,
        predefinedCategory: AllergyPredefinedCategory = .other,
        customCategory: AllergyCategory? = nil,
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

enum AllergyPredefinedCategory: String, CaseIterable, Codable, PredefinedCategoryType {
    case food
    case medication
    case environmental
    case dietary
    case other

    nonisolated var displayName: String {
        switch self {
        case .food: String(localized: "Food", comment: "Allergy category: food")
        case .medication: String(localized: "Medication", comment: "Allergy category: medication")
        case .environmental: String(localized: "Environmental", comment: "Allergy category: environmental")
        case .dietary: String(localized: "Dietary", comment: "Allergy category: dietary")
        case .other: String(localized: "Other", comment: "Allergy category: other")
        }
    }

    nonisolated var icon: String {
        switch self {
        case .food: "fork.knife"
        case .medication: "pills.fill"
        case .environmental: "wind"
        case .dietary: "leaf.fill"
        case .other: "square.grid.2x2"
        }
    }

    nonisolated var colorName: String {
        switch self {
        case .food: "terracotta"
        case .medication: "dusk"
        case .environmental: "sage"
        case .dietary: "eucalyptus"
        case .other: "slate"
        }
    }

    nonisolated var isHideable: Bool {
        self != .other
    }
}

// MARK: - CategorizedItem

extension AllergyItem: CategorizedItem, CategorizedItemMutating {
    var resolvedPredefinedCategory: AllergyPredefinedCategory {
        predefinedCategory
    }
}
