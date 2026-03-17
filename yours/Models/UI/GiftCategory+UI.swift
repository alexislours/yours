import SwiftUI

extension GiftCategory {
    var color: Color {
        CategoryPalette.color(for: colorName)
    }
}
