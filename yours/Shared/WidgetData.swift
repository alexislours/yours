import Foundation

struct WidgetPersonData: Codable {
    let name: String
    let relationshipStart: Date
    let durationDescription: String
    let formattedStartDate: String
    let photoData: Data?
    let hasCompletedOnboarding: Bool
}

struct WidgetDateData: Codable {
    let title: String
    let icon: String
    let daysUntilNext: Int
    let countdownText: String
    let isToday: Bool
}

struct WidgetPayload: Codable {
    let person: WidgetPersonData?
    let upcomingDates: [WidgetDateData]
    let lastUpdated: Date
}
