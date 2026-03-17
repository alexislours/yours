import SwiftUI

extension AllergyCategory {
    var color: Color {
        CategoryPalette.color(for: colorName)
    }
}
