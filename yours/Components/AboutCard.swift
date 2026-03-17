import SwiftUI

struct AboutCard: View {
    let title: String
    let icon: String
    let iconColor: Color
    let iconBackground: Color
    let previewText: String?
    let countText: String?

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            IconBadge(
                systemName: icon,
                iconColor: iconColor,
                backgroundColor: iconBackground,
                size: 32
            )

            Text(title.uppercased())
                .font(.sectionLabel)
                .foregroundStyle(Color.textTertiary)

            if let previewText {
                Text(previewText)
                    .font(.bodySmall)
                    .foregroundStyle(Color.textPrimary)
                    .lineLimit(1)
            } else {
                Text(String(localized: "None yet", comment: "About card: placeholder when no items exist"))
                    .font(.bodySmall)
                    .foregroundStyle(Color.textTertiary)
            }

            Spacer(minLength: 0)

            if let countText {
                CountBadge(text: countText)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 140, alignment: .leading)
        .cardStyle()
    }
}

#Preview {
    HStack(spacing: Spacing.md) {
        AboutCard(
            title: "Likes",
            icon: "heart.fill",
            iconColor: .accentSecondary,
            iconBackground: .accentSecondarySoft,
            previewText: "Sunset walks",
            countText: "3 likes"
        )
        AboutCard(
            title: "Dislikes",
            icon: "heart.slash",
            iconColor: .accentRose,
            iconBackground: .accentRoseSoft,
            previewText: nil,
            countText: nil
        )
    }
    .padding(Spacing.xxxl)
}
