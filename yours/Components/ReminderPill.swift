import SwiftUI

struct ReminderPill: View {
    let icon: String
    let text: String
    let color: Color

    var body: some View {
        HStack(spacing: Spacing.xs) {
            Image(systemName: icon)
                .font(.custom(FontFamily.ui, size: 14, relativeTo: .subheadline))
            Text(text)
                .font(.bodySmall)
                .fontWeight(.medium)
        }
        .foregroundStyle(color)
        .padding(.vertical, Spacing.xs)
        .padding(.horizontal, 14)
        .background(color.opacity(Opacity.subtleBorder), in: Capsule())
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    ReminderPill(
        icon: "gift",
        text: "Her birthday is in 12 days",
        color: .accentPrimary
    )
}
