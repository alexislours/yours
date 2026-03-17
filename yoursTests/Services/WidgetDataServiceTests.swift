import Foundation
import SwiftData
import Testing
import UIKit
@testable import yours

// MARK: - Mock

@MainActor
final class MockWidgetReloader: WidgetReloading {
    var reloadCallCount = 0

    func reloadAllTimelines() {
        reloadCallCount += 1
    }
}

// MARK: - Tests

@Suite("WidgetDataService", .tags(.services, .widgets), .serialized)
@MainActor
struct WidgetDataServiceTests {
    init() {
        // Clear both file and UserDefaults storage between tests
        let suite = SharedDefaults.suiteName
        if let url = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: suite
        )?.appendingPathComponent(SharedDefaults.fileName) {
            try? FileManager.default.removeItem(at: url)
        }
        UserDefaults(suiteName: suite)?.removeObject(forKey: "widgetPayload")
    }

    @Test("Sync encodes at most 5 upcoming dates")
    func syncCapsAtFiveDates() throws {
        let ctx = TestSupport.makeContext()
        let person = TestSupport.seedPerson(in: ctx)

        for i in 0 ..< 8 {
            TestSupport.seedImportantDate(
                in: ctx,
                title: "Date \(i)",
                date: TestFixtures.futureDate(daysFromNow: i + 1),
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

        #expect(person.upcomingDates.count == 8)
        #expect(payload.upcomingDates.count == 5)
    }

    @Test("Photos are downsized in widget payload")
    func photosAreDownsized() throws {
        let ctx = TestSupport.makeContext()
        let person = TestSupport.seedPerson(in: ctx)

        // Create a large image using scale 1 for deterministic pixel dimensions
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 600, height: 600), format: format)
        let largeImage = renderer.image { context in
            UIColor.blue.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 600, height: 600))
        }
        let originalData = largeImage.pngData()!
        person.photoData = originalData
        try ctx.save()

        let reloader = MockWidgetReloader()
        WidgetDataService.sync(modelContext: ctx, widgetReloader: reloader)

        let stored = try #require(SharedDefaults.read())
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let payload = try decoder.decode(WidgetPayload.self, from: stored)
        let widgetPhotoData = try #require(payload.person?.photoData)

        // Widget photo should be smaller than the original
        #expect(widgetPhotoData.count < originalData.count)

        // Verify the resized image dimensions are at most 300px
        let resized = try #require(UIImage(data: widgetPhotoData))
        #expect(resized.size.width <= 300)
        #expect(resized.size.height <= 300)
    }

    @Test("Payload round-trips correctly through encode/decode")
    func payloadRoundTrip() throws {
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

        let reloader = MockWidgetReloader()
        WidgetDataService.sync(modelContext: ctx, widgetReloader: reloader)

        let data = SharedDefaults.read()!
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let payload = try decoder.decode(WidgetPayload.self, from: data)

        #expect(payload.person?.name == "Alice")
        #expect(payload.person?.hasCompletedOnboarding == true)
        #expect(payload.upcomingDates.count == 1)
        #expect(payload.upcomingDates.first?.title == "Birthday")
    }

    @Test("Sync posts a WidgetKit reload")
    func syncReloadsWidgets() {
        let ctx = TestSupport.makeContext()
        TestSupport.seedPerson(in: ctx)

        let reloader = MockWidgetReloader()
        WidgetDataService.sync(modelContext: ctx, widgetReloader: reloader)

        #expect(reloader.reloadCallCount == 1)
    }
}
