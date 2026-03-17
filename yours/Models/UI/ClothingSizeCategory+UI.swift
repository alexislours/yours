import SwiftUI

extension ClothingSizeCategory {
    var color: Color {
        CategoryPalette.color(for: colorName)
    }
}
