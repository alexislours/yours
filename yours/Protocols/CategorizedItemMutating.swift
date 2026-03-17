import SwiftData

/// Protocol for items whose category can be mutated (update + create paths).
/// Eliminates duplicated category-assignment logic across all categorized item services.
protocol CategorizedItemMutating: AnyObject, CategorizedItem where PredefinedCat: PredefinedCategoryType {
    var customCategory: CustomCat? { get set }
    var predefinedCategory: PredefinedCat { get set }
}

extension CategorizedItemMutating {
    /// Apply category selection consistently across all categorized item services (update path).
    func applyCategorySelection(
        useCustom: Bool,
        custom: CustomCat?,
        predefined: PredefinedCat,
        fallback: PredefinedCat
    ) {
        if useCustom {
            customCategory = custom
            predefinedCategory = fallback
        } else {
            customCategory = nil
            predefinedCategory = predefined
        }
    }

    /// Returns the (predefined, custom) tuple for use in item initializers (create path).
    static func resolveCategory(
        useCustom: Bool,
        custom: CustomCat?,
        predefined: PredefinedCat,
        fallback: PredefinedCat
    ) -> (predefined: PredefinedCat, custom: CustomCat?) {
        if useCustom {
            (fallback, custom)
        } else {
            (predefined, nil)
        }
    }
}
