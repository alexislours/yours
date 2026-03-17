import SwiftUI

extension LikeDislikeCategory {
    var color: Color {
        CategoryPalette.color(for: colorName)
    }
}
