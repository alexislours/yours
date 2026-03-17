import SwiftUI

struct SectionCard<Content: View>: View {
    let title: String
    let icon: String
    let iconColor: Color
    let iconBackground: Color
    let showAddButton: Bool
    let onAdd: (() -> Void)?
    @ViewBuilder let content: () -> Content

    init(
        title: String,
        icon: String,
        iconColor: Color,
        iconBackground: Color,
        showAddButton: Bool = false,
        onAdd: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self.icon = icon
        self.iconColor = iconColor
        self.iconBackground = iconBackground
        self.showAddButton = showAddButton
        self.onAdd = onAdd
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            // Card header
            HStack {
                IconBadge(
                    systemName: icon,
                    iconColor: iconColor,
                    backgroundColor: iconBackground
                )

                Text(title)
                    .font(.custom(FontFamily.ui, size: 16, relativeTo: .body))
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.textPrimary)

                Spacer()

                if showAddButton {
                    addButton
                }

                Image(systemName: "chevron.right")
                    .font(.custom(FontFamily.ui, size: 14, relativeTo: .subheadline).weight(.medium))
                    .foregroundStyle(Color.textTertiary)
                    .accessibilityHidden(true)
            }

            content()
        }
        .cardStyle(padding: Spacing.xl)
    }

    private var addButton: some View {
        Button(action: { onAdd?() }, label: {
            Circle()
                .fill(Color.accentPrimary)
                .frame(width: 28, height: 28)
                .overlay(
                    Image(systemName: "plus")
                        .font(.custom(FontFamily.ui, size: 13, relativeTo: .footnote).weight(.bold))
                        .foregroundStyle(Color.textOnAccent)
                )
        })
        .buttonStyle(.plain)
        .frame(minWidth: 44, minHeight: 44)
        .contentShape(Circle())
        .accessibilityLabel(
            String(localized: "Add \(title)", comment: "Accessibility: add button label for section card")
        )
    }
}

// MARK: - Convenience for preview/count row

struct SectionCardPreviewRow: View {
    let preview: String
    let badge: String?

    var body: some View {
        HStack {
            Text(preview)
                .font(.custom(FontFamily.ui, size: 14, relativeTo: .subheadline))
                .foregroundStyle(Color.textSecondary)
                .lineLimit(1)

            Spacer()

            if let badge {
                CountBadge(text: badge)
            }
        }
    }
}

struct SectionCardBodyRow: View {
    let text: String
    let timestamp: String

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text(text)
                .font(.custom(FontFamily.ui, size: 14, relativeTo: .subheadline))
                .foregroundStyle(Color.textSecondary)
                .lineSpacing(3)

            Text(timestamp)
                .font(.caption)
                .foregroundStyle(Color.textTertiary)
        }
    }
}

#Preview {
    VStack(spacing: Spacing.md) {
        SectionCard(
            title: "Important dates",
            icon: "calendar",
            iconColor: .accentSecondary,
            iconBackground: .accentSecondarySoft
        ) {
            SectionCardPreviewRow(preview: "Mom's birthday, April 3", badge: "8 dates")
        }

        SectionCard(
            title: "Notes",
            icon: "note.text",
            iconColor: .accentSecondary,
            iconBackground: .accentSecondarySoft,
            showAddButton: true
        ) {
            SectionCardBodyRow(
                text: "She said something about wanting to visit Kyoto in spring...",
                timestamp: "Last entry 3 days ago"
            )
        }
    }
    .padding()
    .background(Color.bgPrimary)
}
