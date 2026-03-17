import SwiftUI
import WidgetKit

// MARK: - Entry

struct RelationshipDurationEntry: TimelineEntry {
    let date: Date
    let name: String
    let relationshipStart: Date
    let durationDescription: String
    let formattedStartDate: String
    let photoData: Data?
    let upcomingDates: [WidgetDateData]
    let hasCompletedOnboarding: Bool
}

// MARK: - Provider

struct RelationshipDurationProvider: TimelineProvider {
    func placeholder(in _: Context) -> RelationshipDurationEntry {
        let start = Calendar.current.date(byAdding: .month, value: -27, to: .now) ?? .now
        return RelationshipDurationEntry(
            date: .now,
            name: "Alex",
            relationshipStart: start,
            durationDescription: String(
                localized: "Together for 2 years and 3 months.",
                comment: "Widget placeholder: relationship duration"
            ),
            formattedStartDate: start.formatted(.dateTime.month(.wide).day().year()),
            photoData: nil,
            upcomingDates: [],
            hasCompletedOnboarding: true
        )
    }

    func getSnapshot(in _: Context, completion: @escaping (RelationshipDurationEntry) -> Void) {
        completion(loadEntry())
    }

    func getTimeline(
        in _: Context,
        completion: @escaping (Timeline<RelationshipDurationEntry>) -> Void
    ) {
        let entry = loadEntry()
        let midnight = Calendar.current.startOfDay(
            for: Calendar.current.date(byAdding: .day, value: 1, to: .now) ?? .now
        )
        completion(Timeline(entries: [entry], policy: .after(midnight)))
    }

    private func loadEntry() -> RelationshipDurationEntry {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        guard let data = SharedDefaults.read(),
              let payload = try? decoder.decode(WidgetPayload.self, from: data),
              let person = payload.person
        else {
            return RelationshipDurationEntry(
                date: .now,
                name: "",
                relationshipStart: .now,
                durationDescription: "",
                formattedStartDate: "",
                photoData: nil,
                upcomingDates: [],
                hasCompletedOnboarding: false
            )
        }

        return RelationshipDurationEntry(
            date: .now,
            name: person.name,
            relationshipStart: person.relationshipStart,
            durationDescription: person.durationDescription,
            formattedStartDate: person.formattedStartDate,
            photoData: person.photoData,
            upcomingDates: payload.upcomingDates,
            hasCompletedOnboarding: person.hasCompletedOnboarding
        )
    }
}

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
            [.year, .month],
            from: start,
            to: today
        )
        let years = components.year ?? 0
        let months = components.month ?? 0

        if years >= 1, months > 0 {
            return (
                "\(years)y \(months)m",
                String(localized: "together", comment: "Widget medium: together label")
            )
        } else if years >= 1 {
            return (
                "\(years)",
                years == 1
                    ? String(localized: "year together", comment: "Widget medium: singular year")
                    : String(localized: "years together", comment: "Widget medium: plural years")
            )
        } else {
            return (
                "\(months)",
                months == 1
                    ? String(localized: "month together", comment: "Widget medium: singular month")
                    : String(localized: "months together", comment: "Widget medium: plural months")
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
            [.year, .month],
            from: start,
            to: today
        )
        let years = components.year ?? 0
        let months = components.month ?? 0

        if years > 0, months > 0 {
            return String(
                localized: "Together \(years)y \(months)m",
                comment: "Widget Lock Screen: compact duration with years and months"
            )
        } else if years > 0 {
            return String(
                localized: "Together \(years)y",
                comment: "Widget Lock Screen: compact duration years only"
            )
        } else {
            return String(
                localized: "Together \(months)m",
                comment: "Widget Lock Screen: compact duration months only"
            )
        }
    }
}
