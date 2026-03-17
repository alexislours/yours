import SwiftUI

struct IconBadge: View {
    let systemName: String
    let iconColor: Color
    let backgroundColor: Color
    let size: CGFloat
    let cornerRadius: CGFloat

    init(
        systemName: String,
        iconColor: Color,
        backgroundColor: Color,
        size: CGFloat = 36,
        cornerRadius: CGFloat = CornerRadius.sm
    ) {
        self.systemName = systemName
        self.iconColor = iconColor
        self.backgroundColor = backgroundColor
        self.size = size
        self.cornerRadius = cornerRadius
    }

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(backgroundColor)
            .frame(width: size, height: size)
            .overlay(
                Image(systemName: systemName)
                    .font(.custom(FontFamily.ui, size: size * 0.5, relativeTo: .title2))
                    .foregroundStyle(iconColor)
            )
            .accessibilityHidden(true)
    }
}

#Preview {
    HStack(spacing: Spacing.md) {
        IconBadge(systemName: "calendar", iconColor: .accentSecondary, backgroundColor: .accentSecondarySoft)
        IconBadge(systemName: "lightbulb", iconColor: .accentRose, backgroundColor: .accentRoseSoft)
        IconBadge(systemName: "quote.opening", iconColor: .accentPrimary, backgroundColor: .accentPrimarySoft)
    }
}
