import SwiftUI

struct InfoRow: View {
    let icon: String
    var iconColor: Color = .textTertiary
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: Spacing.lg) {
            IconBadge(
                systemName: icon,
                iconColor: iconColor,
                backgroundColor: iconColor.opacity(Opacity.iconBackground),
                size: 32
            )

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(Color.textTertiary)

                Text(value)
                    .font(.bodyDefault)
                    .fontWeight(.medium)
                    .foregroundStyle(Color.textPrimary)
            }

            Spacer()
        }
        .accessibilityElement(children: .combine)
        .cardStyle()
    }
}

struct NoteSection: View {
    let note: String

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack(spacing: Spacing.sm) {
                Image(systemName: "note.text")
                    .font(.custom(FontFamily.ui, size: 12, relativeTo: .caption))
                    .foregroundStyle(Color.textTertiary)
                    .accessibilityHidden(true)
                Text(String(localized: "Note", comment: "Detail view: section label for a note"))
                    .font(.sectionLabel)
                    .foregroundStyle(Color.textTertiary)
            }

            Text(note)
                .font(.custom(FontFamily.ui, size: 14, relativeTo: .subheadline))
                .foregroundStyle(Color.textPrimary)
                .lineSpacing(3)
                .frame(maxWidth: .infinity, alignment: .leading)
                .cardStyle()
        }
    }
}

struct DeleteButton: View {
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action, label: {
            HStack(spacing: Spacing.sm) {
                Image(systemName: "trash")
                    .font(.custom(FontFamily.ui, size: 14, relativeTo: .subheadline))
                    .accessibilityHidden(true)
                Text(label)
                    .font(.custom(FontFamily.ui, size: 14, relativeTo: .subheadline))
                    .fontWeight(.medium)
            }
            .foregroundStyle(Color.error)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.lg)
            .background(Color.error.opacity(Opacity.subtleBackground))
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.lg)
                    .strokeBorder(Color.error.opacity(Opacity.subtleBorder), lineWidth: 1)
            )
        })
        .buttonStyle(.pressable)
    }
}
