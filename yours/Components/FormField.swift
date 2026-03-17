import SwiftUI

struct FormField<Content: View>: View {
    let label: String
    var isFocused: Bool = false
    @ViewBuilder let content: Content

    init(_ label: String, isFocused: Bool = false, @ViewBuilder content: () -> Content) {
        self.label = label
        self.isFocused = isFocused
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text(label)
                .font(.sectionLabel)
                .foregroundStyle(Color.textTertiary)
                .accessibilityHidden(true)

            content
                .padding(.horizontal, Spacing.lg)
                .padding(.vertical, Spacing.md)
                .background(Color.bgSurface)
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
                .overlay(
                    RoundedRectangle(cornerRadius: CornerRadius.md)
                        .strokeBorder(
                            isFocused ? Color.accentPrimary : Color.borderSubtle,
                            lineWidth: isFocused ? 1.5 : 1
                        )
                        .animation(.motionAware(.easeInOut(duration: 0.2)), value: isFocused)
                )
                .accessibilityLabel(label)
        }
    }
}
