import SwiftData
import SwiftUI

/// Shared category-resolution logic for item models that have a predefined category
/// enum and an optional custom category. Eliminates duplicated computed properties
/// across 7 model files.
///
/// Models with standard behavior (AllergyItem, LikeDislikeItem, FoodOrderItem,
/// ClothingSizeItem, TheirPeopleItem) get all four properties for free.
/// Models with edge cases (ImportantDate, GiftIdea) override specific properties.
protocol CategorizedItem {
    associatedtype CustomCat: ManageableCategory & PersistentModel
    associatedtype PredefinedCat: PredefinedCategoryType

    var customCategory: CustomCat? { get }

    /// The resolved predefined category (handles optional predefined categories
    /// by requiring conformers to provide a resolved value).
    var resolvedPredefinedCategory: PredefinedCat { get }
}

// MARK: - Default Implementations

extension CategorizedItem {
    var categoryDisplayName: String {
        if let custom = customCategory {
            return custom.name
        }
        return resolvedPredefinedCategory.displayName
    }

    var categoryIcon: String {
        if let custom = customCategory {
            return custom.sfSymbol
        }
        return resolvedPredefinedCategory.icon
    }

    var categoryColor: Color {
        if let custom = customCategory {
            return CategoryPalette.color(for: custom.colorName)
        }
        return resolvedPredefinedCategory.color
    }

    var categoryGroupKey: String {
        if let custom = customCategory {
            return "custom:\(custom.persistentModelID)"
        }
        return resolvedPredefinedCategory.rawValue
    }
}
