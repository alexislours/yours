import Foundation
import SwiftData

@Model
final class FoodOrderItem {
    var place: String = ""
    var order: String = ""
    var note: String?
    var predefinedCategory: FoodOrderPredefinedCategory = FoodOrderPredefinedCategory.other
    var customCategory: FoodOrderCategory?
    var sortOrder: Int = 0
    var createdAt: Date = Date.now
    var updatedAt: Date = Date.now
    var person: Person?

    init(
        place: String,
        order: String,
        note: String? = nil,
        predefinedCategory: FoodOrderPredefinedCategory = .coffee,
        customCategory: FoodOrderCategory? = nil,
        sortOrder: Int = 0,
        person: Person
    ) {
        self.place = place
        self.order = order
        self.note = note
        self.predefinedCategory = predefinedCategory
        self.customCategory = customCategory
        self.sortOrder = sortOrder
        createdAt = .now
        updatedAt = .now
        self.person = person
    }
}

// MARK: - Predefined Categories

enum FoodOrderPredefinedCategory: String, CaseIterable, Codable, PredefinedCategoryType {
    case coffee
    case breakfast
    case lunch
    case dinner
    case takeout
    case fastfood
    case drinks
    case dessert
    case other

    nonisolated var displayName: String {
        switch self {
        case .coffee: String(localized: "Coffee", comment: "Food order category: coffee")
        case .breakfast: String(localized: "Breakfast", comment: "Food order category: breakfast")
        case .lunch: String(localized: "Lunch", comment: "Food order category: lunch")
        case .dinner: String(localized: "Dinner", comment: "Food order category: dinner")
        case .takeout: String(localized: "Takeout", comment: "Food order category: takeout")
        case .fastfood: String(localized: "Fast Food", comment: "Food order category: fast food")
        case .drinks: String(localized: "Drinks", comment: "Food order category: drinks")
        case .dessert: String(localized: "Dessert", comment: "Food order category: dessert")
        case .other: String(localized: "Other", comment: "Food order category: other")
        }
    }

    nonisolated var icon: String {
        switch self {
        case .coffee: "cup.and.saucer.fill"
        case .breakfast: "sunrise.fill"
        case .lunch: "fork.knife"
        case .dinner: "moon.stars.fill"
        case .takeout: "bag.fill"
        case .fastfood: "flame.fill"
        case .drinks: "wineglass.fill"
        case .dessert: "birthday.cake.fill"
        case .other: "square.grid.2x2"
        }
    }

    nonisolated var colorName: String {
        switch self {
        case .coffee: "clay"
        case .breakfast: "amber"
        case .lunch: "sage"
        case .dinner: "dusk"
        case .takeout: "terracotta"
        case .fastfood: "ochre"
        case .drinks: "slate"
        case .dessert: "rose"
        case .other: "slate"
        }
    }

    /// Fixed display order for predefined categories
    nonisolated var displayOrder: Int {
        switch self {
        case .coffee: 0
        case .breakfast: 1
        case .lunch: 2
        case .dinner: 3
        case .takeout: 4
        case .fastfood: 5
        case .drinks: 6
        case .dessert: 7
        case .other: 8
        }
    }
}

// MARK: - CategorizedItem

extension FoodOrderItem: CategorizedItem, CategorizedItemMutating {
    var resolvedPredefinedCategory: FoodOrderPredefinedCategory {
        predefinedCategory
    }
}
