import SwiftUI

extension TheirPeopleCategory {
    var color: Color {
        CategoryPalette.color(for: colorName)
    }
}
