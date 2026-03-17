import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let iconColor: Color
    let title: String
    let description: String
    let buttonLabel: String
    let buttonColor: Color
    let action: () -> Void

    @State private var appeared = false

    init(
        icon: String,
        iconColor: Color,
        title: String,
        description: String,
        buttonLabel: String,
        buttonColor: Color? = nil,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.iconColor = iconColor
        self.title = title
        self.description = description
        self.buttonLabel = buttonLabel
        self.buttonColor = buttonColor ?? iconColor
        self.action = action
    }

    var body: some View {
        VStack(spacing: Spacing.lg) {
            Image(systemName: icon)
                .font(.custom(FontFamily.ui, size: 40, relativeTo: .largeTitle).weight(.light))
                .foregroundStyle(iconColor)

            VStack(spacing: Spacing.sm) {
                Text(title)
                    .font(.heading3)
                    .foregroundStyle(Color.textPrimary)

                Text(description)
                    .font(.bodySmall)
                    .foregroundStyle(Color.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
            }

            Button(action: action) {
                Text(buttonLabel)
                    .font(.label)
                    .foregroundStyle(Color.textOnAccent)
                    .padding(.horizontal, Spacing.xxl)
                    .padding(.vertical, Spacing.sm)
                    .background(buttonColor, in: Capsule())
            }
            .buttonStyle(.pressable)
            .padding(.top, Spacing.xs)
        }
        .padding(.horizontal, Spacing.xxxl)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 8)
        .onAppear {
            withOptionalAnimation(.emptyState) {
                appeared = true
            }
        }
    }
}
