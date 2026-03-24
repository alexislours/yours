import SwiftUI
import WidgetKit

// MARK: - Entry

struct DateCountdownEntry: TimelineEntry {
    let date: Date
    let dates: [WidgetDateData]
    let hasCompletedOnboarding: Bool
}

// MARK: - Provider

struct DateCountdownProvider: TimelineProvider {
    func placeholder(in _: Context) -> DateCountdownEntry {
        DateCountdownEntry(
            date: .now,
            dates: [
                WidgetDateData(
                    title: String(localized: "Birthday", comment: "Widget placeholder: example event"),
                    icon: "birthday.cake.fill",
                    nextOccurrence: Calendar.current.date(
                        byAdding: .day, value: 12, to: .now
                    ) ?? .now
                ),
            ],
            hasCompletedOnboarding: true
        )
    }

    func getSnapshot(in _: Context, completion: @escaping (DateCountdownEntry) -> Void) {
        completion(loadEntry())
    }

    func getTimeline(in _: Context, completion: @escaping (Timeline<DateCountdownEntry>) -> Void) {
        let entry = loadEntry()
        let midnight = Calendar.current.startOfDay(
            for: Calendar.current.date(byAdding: .day, value: 1, to: .now) ?? .now
        )
        completion(Timeline(entries: [entry], policy: .after(midnight)))
    }

    private func loadEntry() -> DateCountdownEntry {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        guard let data = SharedDefaults.read(),
              let payload = try? decoder.decode(WidgetPayload.self, from: data)
        else {
            return DateCountdownEntry(date: .now, dates: [], hasCompletedOnboarding: false)
        }

        return DateCountdownEntry(
            date: .now,
            dates: payload.upcomingDates,
            hasCompletedOnboarding: payload.person?.hasCompletedOnboarding ?? false
        )
    }
}

// MARK: - Widget

struct DateCountdownWidget: Widget {
    let kind = "DateCountdownWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DateCountdownProvider()) { entry in
            DateCountdownWidgetView(entry: entry)
                .containerBackground(for: .widget) {
                    Color(.bgPrimary)
                }
        }
        .configurationDisplayName(
            String(localized: "Date Countdown", comment: "Widget gallery: date countdown name")
        )
        .description(
            String(localized: "See upcoming important dates at a glance.", comment: "Widget gallery: date countdown description")
        )
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
        // System content margins provide consistent spacing
    }
}

// MARK: - Views

struct DateCountdownWidgetView: View {
    let entry: DateCountdownEntry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        Group {
            if !entry.hasCompletedOnboarding || entry.dates.isEmpty {
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
        .widgetURL(DeepLink.importantDates.url)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "calendar.badge.plus")
                .font(.title2)
                .foregroundStyle(Color(.accentPrimary).opacity(0.6))
                .widgetAccentable()
            Text("Add an important date", comment: "Widget: empty state prompt")
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
        let item = entry.dates[0]
        return VStack(alignment: .leading, spacing: 4) {
            Image(systemName: item.icon)
                .font(.callout)
                .foregroundStyle(Color(.accentPrimary))
                .widgetAccentable()

            Spacer()

            Text(item.title)
                .font(.custom("Crimson Pro", size: 18, relativeTo: .title3))
                .fontWeight(.medium)
                .lineLimit(2)
                .foregroundStyle(Color(.textPrimary))

            if item.isToday {
                Text("Today", comment: "Widget: event is today")
                    .font(.custom("Inter", size: 13, relativeTo: .footnote))
                    .fontWeight(.semibold)
                    .foregroundStyle(Color(.accentPrimary))
                    .widgetAccentable()
            } else {
                Text(item.countdownText)
                    .font(.custom("Inter", size: 13, relativeTo: .footnote))
                    .foregroundStyle(Color(.textSecondary))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }

    private var mediumView: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Upcoming", comment: "Widget: upcoming dates header")
                .font(.custom("Inter", size: 11, relativeTo: .caption2))
                .fontWeight(.semibold)
                .textCase(.uppercase)
                .tracking(3)
                .foregroundStyle(Color(.textTertiary))
                .padding(.bottom, 10)

            ForEach(Array(entry.dates.prefix(3).enumerated()), id: \.offset) { _, item in
                dateRow(item)
                    .padding(.vertical, 5)
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }

    private var largeView: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Upcoming", comment: "Widget: upcoming dates header")
                .font(.custom("Inter", size: 11, relativeTo: .caption2))
                .fontWeight(.semibold)
                .textCase(.uppercase)
                .tracking(3)
                .foregroundStyle(Color(.textTertiary))
                .padding(.bottom, 14)

            ForEach(Array(entry.dates.prefix(5).enumerated()), id: \.offset) { _, item in
                dateRow(item)
                    .padding(.vertical, 7)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }

    private func dateRow(_ item: WidgetDateData) -> some View {
        HStack(spacing: 12) {
            Image(systemName: item.icon)
                .font(.callout)
                .foregroundStyle(Color(.accentPrimary))
                .frame(width: 22)
                .widgetAccentable()

            Text(item.title)
                .font(.custom("Crimson Pro", size: 16, relativeTo: .callout))
                .fontWeight(.medium)
                .foregroundStyle(Color(.textPrimary))
                .lineLimit(1)

            Spacer()

            if item.isToday {
                Text("Today", comment: "Widget: event is today")
                    .font(.custom("Inter", size: 12, relativeTo: .caption))
                    .fontWeight(.semibold)
                    .foregroundStyle(Color(.accentPrimary))
                    .widgetAccentable()
            } else {
                Text(item.countdownText)
                    .font(.custom("Inter", size: 13, relativeTo: .footnote))
                    .foregroundStyle(Color(.textSecondary))
            }
        }
    }
}
