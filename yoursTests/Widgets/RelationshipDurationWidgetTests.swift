import Foundation
import SwiftData
import Testing
@testable import yours

@Suite("RelationshipDurationWidget", .tags(.widgets), .serialized)
@MainActor
struct RelationshipDurationWidgetTests {
    init() {
        let suite = SharedDefaults.suiteName
        if let url = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: suite
        )?.appendingPathComponent(SharedDefaults.fileName) {
            try? FileManager.default.removeItem(at: url)
        }
        UserDefaults(suiteName: suite)?.removeObject(forKey: "widgetPayload")
    }

    // MARK: - Small: compact duration

    @Test("Payload includes duration description for compact display")
    func smallShowsCompactDuration() throws {
        let ctx = TestSupport.makeContext()
        TestSupport.seedPerson(
            in: ctx,
            name: "Alice",
            relationshipStart: TestFixtures.sampleRelationshipStart
        )

        let reloader = MockWidgetReloader()
        WidgetDataService.sync(modelContext: ctx, widgetReloader: reloader)

        let data = try #require(SharedDefaults.read())
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let payload = try decoder.decode(WidgetPayload.self, from: data)

        #expect(payload.person?.name == "Alice")
        #expect(payload.person?.relationshipStart == TestFixtures.sampleRelationshipStart)
        #expect(payload.person?.durationDescription.isEmpty == false)
    }

    // MARK: - Medium: years/months breakdown

    @Test("Payload includes relationship start for years/months calculation")
    func mediumShowsYearsMonthsBreakdown() throws {
        let ctx = TestSupport.makeContext()
        TestSupport.seedPerson(
            in: ctx,
            relationshipStart: TestFixtures.sampleRelationshipStart
        )

        let reloader = MockWidgetReloader()
        WidgetDataService.sync(modelContext: ctx, widgetReloader: reloader)

        let data = try #require(SharedDefaults.read())
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let payload = try decoder.decode(WidgetPayload.self, from: data)

        let person = try #require(payload.person)
        #expect(person.relationshipStart == TestFixtures.sampleRelationshipStart)
        #expect(person.formattedStartDate.isEmpty == false)
    }

    // MARK: - Large: includes upcoming dates

    @Test("Payload includes upcoming dates for large widget display")
    func largeIncludesUpcomingDates() throws {
        let ctx = TestSupport.makeContext()
        let person = TestSupport.seedPerson(
            in: ctx,
            name: "Alice",
            relationshipStart: TestFixtures.sampleRelationshipStart
        )

        TestSupport.seedImportantDate(
            in: ctx,
            title: "Birthday",
            date: TestFixtures.futureDate(daysFromNow: 10),
            recurrenceFrequency: .yearly,
            predefinedCategory: .birthday,
            person: person
        )
        TestSupport.seedImportantDate(
            in: ctx,
            title: "Anniversary",
            date: TestFixtures.futureDate(daysFromNow: 30),
            recurrenceFrequency: .yearly,
            predefinedCategory: .anniversary,
            person: person
        )

        let reloader = MockWidgetReloader()
        WidgetDataService.sync(modelContext: ctx, widgetReloader: reloader)

        let data = try #require(SharedDefaults.read())
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let payload = try decoder.decode(WidgetPayload.self, from: data)

        // Large view shows up to 3 upcoming dates
        #expect(payload.upcomingDates.count == 2)
        #expect(payload.upcomingDates[0].title == "Birthday")
        #expect(payload.upcomingDates[1].title == "Anniversary")
        #expect(payload.person?.durationDescription.isEmpty == false)
        #expect(payload.person?.formattedStartDate.isEmpty == false)
    }

    // MARK: - Deep link

    @Test("Deep link points to home")
    func deepLinkURL() {
        #expect(DeepLink.home.url == URL(string: "yours://home")!)
    }

    // MARK: - Empty state

    @Test("Empty state when onboarding not completed")
    func emptyStatePreOnboarding() throws {
        let ctx = TestSupport.makeContext()

        let reloader = MockWidgetReloader()
        WidgetDataService.sync(modelContext: ctx, widgetReloader: reloader)

        let data = try #require(SharedDefaults.read())
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let payload = try decoder.decode(WidgetPayload.self, from: data)

        #expect(payload.person == nil)
    }
}
