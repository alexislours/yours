import Foundation

struct WidgetPersonData: Codable {
    let name: String
    let relationshipStart: Date
    let formattedStartDate: String
    let photoData: Data?
    let hasCompletedOnboarding: Bool
}

struct WidgetDateData: Codable {
    let title: String
    let icon: String
    let nextOccurrence: Date

    var daysUntilNext: Int {
        let calendar = Calendar.current
        let now = calendar.startOfDay(for: .now)
        let next = calendar.startOfDay(for: nextOccurrence)
        return max(0, calendar.dateComponents([.day], from: now, to: next).day ?? 0)
    }

    var isToday: Bool {
        daysUntilNext == 0
    }

    var countdownText: String {
        let days = daysUntilNext
        if days == 0 { return String(localized: "Today", comment: "Countdown: event is today") }
        if days == 1 { return String(localized: "Tomorrow", comment: "Countdown: event is tomorrow") }
        return String(localized: "in \(days) days", comment: "Countdown: days until event")
    }
}

struct WidgetPayload: Codable {
    let person: WidgetPersonData?
    let upcomingDates: [WidgetDateData]
    let lastUpdated: Date
}
