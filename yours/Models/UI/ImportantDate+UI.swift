import SwiftUI

extension ImportantDatePredefinedCategory {
    var color: Color {
        Color(colorName)
    }
}

extension ImportantDate {
    /// Override: uses Color(colorName) instead of CategoryPalette for predefined categories.
    var categoryColor: Color {
        if let custom = customCategory {
            return CategoryPalette.color(for: custom.colorName)
        }
        return Color(predefinedCategory.colorName)
    }
}
