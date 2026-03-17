import SwiftUI

struct SelectableChip: View {
    let label: String
    var icon: String?
    let isSelected: Bool
    var selectedBackground: Color = .accentPrimary
    var unselectedBackground: Color?
    var unselectedForeground: Color = .textSecondary
    var showBorder: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.xs) {
                if let icon {
                    Image(systemName: icon)
                        .font(.custom(FontFamily.ui, size: 12, relativeTo: .caption))
                }
                Text(label)
                    .font(.bodySmall)
                    .fontWeight(.medium)
            }
            .foregroundStyle(isSelected ? Color.textOnAccent : unselectedForeground)
            .padding(.horizontal, icon != nil ? Spacing.md : Spacing.lg)
            .padding(.vertical, Spacing.xs)
            .background(
                isSelected ? selectedBackground : (unselectedBackground ?? selectedBackground.opacity(Opacity.iconBackground)),
                in: Capsule()
            )
            .overlay(
                Capsule()
                    .strokeBorder(
                        showBorder && !isSelected ? Color.borderSubtle : Color.clear,
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(.pressable)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
