import Foundation
import Testing
@testable import yours

@Suite("WidgetPayload", .tags(.models, .widgets))
@MainActor
struct WidgetPayloadTests {
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    // MARK: - Round-trip

    @Test("Encoding and decoding round-trips without data loss")
    func roundTrip() throws {
        let person = WidgetPersonData(
            name: "Alice",
            relationshipStart: TestFixtures.sampleRelationshipStart,
            durationDescription: "9 months",
            formattedStartDate: "Jun 1, 2025",
            photoData: Data([0xFF, 0xD8]),
            hasCompletedOnboarding: true
        )
        let dates = [
            WidgetDateData(
                title: "Birthday",
                icon: "gift",
                daysUntilNext: 10,
                countdownText: "In 10 days",
                isToday: false
            ),
            WidgetDateData(
                title: "Anniversary",
                icon: "heart",
                daysUntilNext: 0,
                countdownText: "Today",
                isToday: true
            ),
        ]
        let original = WidgetPayload(
            person: person,
            upcomingDates: dates,
            lastUpdated: TestFixtures.referenceDate
        )

        let data = try encoder.encode(original)
        let decoded = try decoder.decode(WidgetPayload.self, from: data)

        #expect(decoded.person?.name == "Alice")
        #expect(decoded.person?.relationshipStart == TestFixtures.sampleRelationshipStart)
        #expect(decoded.person?.durationDescription == "9 months")
        #expect(decoded.person?.formattedStartDate == "Jun 1, 2025")
        #expect(decoded.person?.photoData == Data([0xFF, 0xD8]))
        #expect(decoded.person?.hasCompletedOnboarding == true)
        #expect(decoded.upcomingDates.count == 2)
        #expect(decoded.upcomingDates[0].title == "Birthday")
        #expect(decoded.upcomingDates[1].isToday == true)
        #expect(decoded.lastUpdated == TestFixtures.referenceDate)
    }

    // MARK: - Missing fields

    @Test("Missing optional fields decode with sensible defaults")
    func missingFieldsDecodeGracefully() throws {
        let json = """
        {
            "person": null,
            "upcomingDates": [],
            "lastUpdated": 0
        }
        """
        let payload = try decoder.decode(WidgetPayload.self, from: Data(json.utf8))

        #expect(payload.person == nil)
        #expect(payload.upcomingDates.isEmpty)
    }

    // MARK: - Empty upcoming dates

    @Test("Empty upcoming dates array is handled")
    func emptyUpcomingDates() throws {
        let original = WidgetPayload(
            person: WidgetPersonData(
                name: "Bob",
                relationshipStart: TestFixtures.referenceDate,
                durationDescription: "1 year",
                formattedStartDate: "Jan 15, 2026",
                photoData: nil,
                hasCompletedOnboarding: true
            ),
            upcomingDates: [],
            lastUpdated: TestFixtures.referenceDate
        )

        let data = try encoder.encode(original)
        let decoded = try decoder.decode(WidgetPayload.self, from: data)

        #expect(decoded.upcomingDates.isEmpty)
        #expect(decoded.person?.name == "Bob")
    }

    // MARK: - Nil person (pre-onboarding)

    @Test("Nil person is handled for pre-onboarding state")
    func nilPerson() throws {
        let original = WidgetPayload(
            person: nil,
            upcomingDates: [],
            lastUpdated: TestFixtures.referenceDate
        )

        let data = try encoder.encode(original)
        let decoded = try decoder.decode(WidgetPayload.self, from: data)

        #expect(decoded.person == nil)
        #expect(decoded.upcomingDates.isEmpty)
        #expect(decoded.lastUpdated == TestFixtures.referenceDate)
    }
}
