import SwiftUI
import WidgetKit

// MARK: - Widget

struct RelationshipDurationWidget: Widget {
    let kind = "RelationshipDurationWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: RelationshipDurationProvider()) { entry in
            RelationshipDurationWidgetView(entry: entry)
                .containerBackground(for: .widget) {
                    Color(.bgPrimary)
                }
        }
        .configurationDisplayName(
            String(localized: "Relationship Duration", comment: "Widget gallery: duration name")
        )
        .description(
            String(
                localized: "See how long you've been together.",
                comment: "Widget gallery: duration description"
            )
        )
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
        // System content margins provide consistent spacing
    }
}

// MARK: - Views

struct RelationshipDurationWidgetView: View {
    let entry: RelationshipDurationEntry
    @Environment(\.widgetFamily) private var family

    private var personImage: Image? {
        guard let data = entry.photoData, let uiImage = UIImage(data: data) else {
            return nil
        }
        return Image(uiImage: uiImage)
    }

    var body: some View {
        Group {
            if !entry.hasCompletedOnboarding {
                emptyState
            } else {
                switch family {
                case .systemSmall:
                    smallView
                case .systemMedium:
                    mediumView
                case .systemLarge:
                    largeView
                default:
                    smallView
                }
            }
        }
        .widgetURL(DeepLink.home.url)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "heart")
                .font(.title2)
                .foregroundStyle(Color(.accentRose).opacity(0.6))
                .widgetAccentable()
            Text(
                "Set up Yours to see your relationship here.",
                comment: "Widget: onboarding required"
            )
            .font(.custom("Inter", size: 13, relativeTo: .footnote))
            .foregroundStyle(Color(.textSecondary))
            .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .accessibilityElement(children: .combine)
    }

    // MARK: - Home Screen

    private var smallView: some View {
        VStack(alignment: .leading, spacing: 4) {
            photoView(size: 72)
                .frame(maxWidth: .infinity)

            Spacer(minLength: 0)

            Text(entry.name)
                .font(.custom("Crimson Pro", size: 15, relativeTo: .callout))
                .fontWeight(.medium)
                .foregroundStyle(Color(.accentPrimary))
                .lineLimit(1)
                .widgetAccentable()

            Text(compactDuration)
                .font(.custom("Inter", size: 11, relativeTo: .caption2))
                .foregroundStyle(Color(.textSecondary))
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }

    private var mediumView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.name)
                    .font(.custom("Crimson Pro", size: 20, relativeTo: .title3))
                    .fontWeight(.medium)
                    .foregroundStyle(Color(.accentPrimary))
                    .lineLimit(1)
                    .widgetAccentable()

                Text(durationBreakdown.value)
                    .font(.custom("Crimson Pro", size: 48, relativeTo: .largeTitle))
                    .fontWeight(.light)
                    .foregroundStyle(Color(.textPrimary))

                Text(durationBreakdown.unit)
                    .font(.custom("Inter", size: 11, relativeTo: .caption2))
                    .fontWeight(.semibold)
                    .textCase(.uppercase)
                    .tracking(2)
                    .foregroundStyle(Color(.textTertiary))
            }

            Spacer(minLength: 0)

            photoView(size: 100)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }

    private var durationBreakdown: (value: String, unit: String) {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: entry.relationshipStart)
        let today = calendar.startOfDay(for: .now)
        let components = calendar.dateComponents(
            [.year, .month, .day],
            from: start,
            to: today
        )
        let years = components.year ?? 0
        let months = components.month ?? 0
        let days = components.day ?? 0

        if years >= 1, months > 0 {
            return (
                "\(years)y \(months)m \(days)d",
                String(localized: "together", comment: "Widget medium: together label")
            )
        } else if years >= 1, days > 0 {
            return (
                "\(years)y \(days)d",
                String(localized: "together", comment: "Widget medium: together label")
            )
        } else if years >= 1 {
            return (
                "\(years)",
                years == 1
                    ? String(localized: "year together", comment: "Widget medium: singular year")
                    : String(localized: "years together", comment: "Widget medium: plural years")
            )
        } else if months > 0 {
            return (
                "\(months)m \(days)d",
                String(localized: "together", comment: "Widget medium: together label")
            )
        } else {
            return (
                "\(days)",
                days == 1
                    ? String(localized: "day together", comment: "Widget medium: singular day")
                    : String(localized: "days together", comment: "Widget medium: plural days")
            )
        }
    }

    private var largeView: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 14) {
                photoView(size: 72)

                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.name)
                        .font(.custom("Crimson Pro", size: 22, relativeTo: .title2))
                        .fontWeight(.medium)
                        .foregroundStyle(Color(.accentPrimary))
                        .lineLimit(1)
                        .widgetAccentable()

                    Text(entry.durationDescription)
                        .font(.custom("Inter", size: 13, relativeTo: .footnote))
                        .foregroundStyle(Color(.textSecondary))
                        .lineLimit(2)

                    HStack(spacing: 4) {
                        Image(systemName: "heart.fill")
                            .font(.custom("Inter", size: 9, relativeTo: .caption2))
                            .foregroundStyle(Color(.accentRose))
                            .accessibilityHidden(true)
                        Text(
                            "Since \(entry.formattedStartDate)",
                            comment: "Widget: relationship start date"
                        )
                        .font(.custom("Inter", size: 11, relativeTo: .caption2))
                        .foregroundStyle(Color(.textTertiary))
                    }
                }
            }

            if !entry.upcomingDates.isEmpty {
                Divider()
                    .foregroundStyle(Color(.borderSubtle))
                    .padding(.vertical, 14)

                Text("Upcoming", comment: "Widget: upcoming dates header")
                    .font(.custom("Inter", size: 11, relativeTo: .caption2))
                    .fontWeight(.semibold)
                    .textCase(.uppercase)
                    .tracking(3)
                    .foregroundStyle(Color(.textTertiary))
                    .padding(.bottom, 10)

                ForEach(
                    Array(entry.upcomingDates.prefix(3).enumerated()),
                    id: \.offset
                ) { _, item in
                    HStack(spacing: 10) {
                        Image(systemName: item.icon)
                            .font(.callout)
                            .foregroundStyle(Color(.accentPrimary))
                            .frame(width: 22)
                            .widgetAccentable()

                        Text(item.title)
                            .font(.custom("Crimson Pro", size: 15, relativeTo: .callout))
                            .fontWeight(.medium)
                            .foregroundStyle(Color(.textPrimary))
                            .lineLimit(1)

                        Spacer()

                        Text(item.countdownText)
                            .font(.custom("Inter", size: 12, relativeTo: .caption))
                            .foregroundStyle(Color(.textSecondary))
                    }
                    .padding(.vertical, 4)
                }
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private func photoView(size: CGFloat) -> some View {
        if let image = personImage {
            image
                .resizable()
                .widgetAccentedRenderingMode(.fullColor)
                .scaledToFill()
                .frame(width: size, height: size)
                .clipShape(Circle())
                .overlay {
                    Circle()
                        .strokeBorder(Color(.borderSubtle), lineWidth: 1)
                }
                .accessibilityLabel(entry.name)
        } else {
            WidgetAvatarView(name: entry.name, size: size)
                .widgetAccentable()
        }
    }

    private var compactDuration: String {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: entry.relationshipStart)
        let today = calendar.startOfDay(for: .now)
        let components = calendar.dateComponents(
            [.year, .month, .day],
            from: start,
            to: today
        )
        let years = components.year ?? 0
        let months = components.month ?? 0
        let days = components.day ?? 0

        if years > 0, months > 0 {
            return String(
                localized: "Together \(years)y \(months)m \(days)d",
                comment: "Widget Lock Screen: compact duration with years, months, and days"
            )
        } else if years > 0, days > 0 {
            return String(
                localized: "Together \(years)y \(days)d",
                comment: "Widget Lock Screen: compact duration with years and days"
            )
        } else if years > 0 {
            return String(
                localized: "Together \(years)y",
                comment: "Widget Lock Screen: compact duration years only"
            )
        } else if months > 0 {
            return String(
                localized: "Together \(months)m \(days)d",
                comment: "Widget Lock Screen: compact duration with months and days"
            )
        } else {
            return String(
                localized: "Together \(days)d",
                comment: "Widget Lock Screen: compact duration days only"
            )
        }
    }
}
