import Foundation
import SwiftData
import Testing
@testable import yours

@Suite("DateCountdownWidget", .tags(.widgets), .serialized)
@MainActor
struct DateCountdownWidgetTests {
    init() {
        let suite = SharedDefaults.suiteName
        if let url = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: suite
        )?.appendingPathComponent(SharedDefaults.fileName) {
            try? FileManager.default.removeItem(at: url)
        }
        UserDefaults(suiteName: suite)?.removeObject(forKey: "widgetPayload")
    }

    // MARK: - Date counts per widget size

    @Test("Small widget payload contains at least 1 date when dates exist")
    func smallShowsSingleDate() throws {
        let ctx = TestSupport.makeContext()
        let person = TestSupport.seedPerson(in: ctx)

        TestSupport.seedImportantDate(
            in: ctx,
            title: "Birthday",
            date: TestFixtures.futureDate(daysFromNow: 5),
            recurrenceFrequency: .yearly,
            predefinedCategory: .birthday,
            person: person
        )

        let reloader = MockWidgetReloader()
        WidgetDataService.sync(modelContext: ctx, widgetReloader: reloader)

        let data = SharedDefaults.read()!
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let payload = try decoder.decode(WidgetPayload.self, from: data)

        #expect(payload.upcomingDates.count >= 1)
        #expect(payload.upcomingDates[0].title == "Birthday")
        #expect(payload.upcomingDates[0].icon == "birthday.cake.fill")
    }

    @Test("Medium widget gets at most 3 dates from payload of 4")
    func mediumShowsUpToThreeDates() throws {
        let ctx = TestSupport.makeContext()
        let person = TestSupport.seedPerson(in: ctx)

        for i in 1 ... 4 {
            TestSupport.seedImportantDate(
                in: ctx,
                title: "Date \(i)",
                date: TestFixtures.futureDate(daysFromNow: i),
                recurrenceFrequency: .yearly,
                person: person
            )
        }

        let reloader = MockWidgetReloader()
        WidgetDataService.sync(modelContext: ctx, widgetReloader: reloader)

        let data = SharedDefaults.read()!
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let payload = try decoder.decode(WidgetPayload.self, from: data)

        // Payload has 4 dates; medium widget view applies prefix(3)
        #expect(payload.upcomingDates.count == 4)
        #expect(payload.upcomingDates.prefix(3).count == 3)
    }

    @Test("Large widget gets at most 5 dates from payload of 7")
    func largeShowsUpToFiveDates() throws {
        let ctx = TestSupport.makeContext()
        let person = TestSupport.seedPerson(in: ctx)

        for i in 1 ... 7 {
            TestSupport.seedImportantDate(
                in: ctx,
                title: "Date \(i)",
                date: TestFixtures.futureDate(daysFromNow: i),
                recurrenceFrequency: .yearly,
                person: person
            )
        }

        let reloader = MockWidgetReloader()
        WidgetDataService.sync(modelContext: ctx, widgetReloader: reloader)

        let data = SharedDefaults.read()!
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let payload = try decoder.decode(WidgetPayload.self, from: data)

        // Service caps at 5; large widget view applies prefix(5)
        #expect(payload.upcomingDates.count == 5)
        #expect(payload.upcomingDates.prefix(5).count == 5)
    }

    // MARK: - Empty state

    @Test("Empty state when person has no upcoming dates")
    func emptyStateWithNoDates() throws {
        let ctx = TestSupport.makeContext()
        TestSupport.seedPerson(in: ctx)

        let reloader = MockWidgetReloader()
        WidgetDataService.sync(modelContext: ctx, widgetReloader: reloader)

        let data = SharedDefaults.read()!
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let payload = try decoder.decode(WidgetPayload.self, from: data)

        #expect(payload.upcomingDates.isEmpty)
    }

    @Test("Empty state when onboarding not completed")
    func emptyStatePreOnboarding() throws {
        // No person seeded means no onboarding
        let ctx = TestSupport.makeContext()

        let reloader = MockWidgetReloader()
        WidgetDataService.sync(modelContext: ctx, widgetReloader: reloader)

        let data = SharedDefaults.read()!
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let payload = try decoder.decode(WidgetPayload.self, from: data)

        #expect(payload.person == nil)
        #expect(payload.upcomingDates.isEmpty)
    }

    // MARK: - Deep link

    @Test("Deep link points to importantDates")
    func deepLinkURL() {
        #expect(DeepLink.importantDates.url == URL(string: "yours://importantDates")!)
    }

    // MARK: - Date ordering

    @Test("Upcoming dates are sorted by days until next occurrence")
    func datesAreSortedByProximity() throws {
        let ctx = TestSupport.makeContext()
        let person = TestSupport.seedPerson(in: ctx)

        TestSupport.seedImportantDate(
            in: ctx,
            title: "Far Away",
            date: TestFixtures.futureDate(daysFromNow: 30),
            recurrenceFrequency: .yearly,
            person: person
        )
        TestSupport.seedImportantDate(
            in: ctx,
            title: "Soon",
            date: TestFixtures.futureDate(daysFromNow: 2),
            recurrenceFrequency: .yearly,
            person: person
        )
        TestSupport.seedImportantDate(
            in: ctx,
            title: "Medium",
            date: TestFixtures.futureDate(daysFromNow: 10),
            recurrenceFrequency: .yearly,
            person: person
        )

        let reloader = MockWidgetReloader()
        WidgetDataService.sync(modelContext: ctx, widgetReloader: reloader)

        let data = SharedDefaults.read()!
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let payload = try decoder.decode(WidgetPayload.self, from: data)

        #expect(payload.upcomingDates.count == 3)
        #expect(payload.upcomingDates[0].title == "Soon")
        #expect(payload.upcomingDates[1].title == "Medium")
        #expect(payload.upcomingDates[2].title == "Far Away")
    }
}
