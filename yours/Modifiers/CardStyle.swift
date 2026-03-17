import SwiftUI

struct CardStyleModifier: ViewModifier {
    var padding: CGFloat = Spacing.lg
    var cornerRadius: CGFloat = CornerRadius.lg

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(Color.bgSurface)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(Color.borderSubtle, lineWidth: 1)
            )
    }
}

extension View {
    func cardStyle(
        padding: CGFloat = Spacing.lg,
        cornerRadius: CGFloat = CornerRadius.lg
    ) -> some View {
        modifier(CardStyleModifier(padding: padding, cornerRadius: cornerRadius))
    }
}
