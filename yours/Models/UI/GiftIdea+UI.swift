import SwiftUI

extension GiftStatus {
    var color: Color {
        switch self {
        case .idea: Color.accentPrimary
        case .purchased: Color.accentSecondary
        case .given: Color(.positive)
        case .archived: Color.textTertiary
        }
    }
}

extension GiftOccasion {
    var color: Color {
        Color(colorName)
    }
}
