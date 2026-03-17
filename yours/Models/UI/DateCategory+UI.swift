import SwiftUI

extension DateCategory {
    var color: Color {
        CategoryPalette.color(for: colorName)
    }
}
