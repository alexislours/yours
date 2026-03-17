import SwiftUI

extension FoodOrderCategory {
    var color: Color {
        CategoryPalette.color(for: colorName)
    }
}
