import SwiftUI
import WidgetKit

// MARK: - Entry

struct RelationshipDurationEntry: TimelineEntry {
    let date: Date
    let name: String
    let relationshipStart: Date
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
            formattedStartDate: person.formattedStartDate,
            photoData: person.photoData,
            upcomingDates: payload.upcomingDates,
            hasCompletedOnboarding: person.hasCompletedOnboarding
        )
    }
}
