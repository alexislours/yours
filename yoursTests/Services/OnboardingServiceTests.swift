import Foundation
import SwiftData
import Testing
import UIKit
@testable import yours

@Suite("OnboardingService", .tags(.services, .onboarding))
@MainActor
struct OnboardingServiceTests {
    @Test("Creates a Person with correct name, gender, and relationship start")
    func completeSetsPersonFields() async throws {
        let ctx = TestSupport.makeContext()
        let reloader = MockWidgetReloader()
        let registrar = MockShortcutRegistrar()
        let date = TestFixtures.sampleRelationshipStart

        let input = OnboardingService.Input(
            name: "Alice", photo: nil, gender: .female,
            startDate: date, firstLike: ""
        )
        await OnboardingService.complete(input, modelContext: ctx, widgetReloader: reloader, shortcutRegistrar: registrar)

        let person = try #require(try ctx.fetch(FetchDescriptor<Person>()).first)
        #expect(person.name == "Alice")
        #expect(person.gender == .female)
        #expect(person.relationshipStart == date)
    }

    @Test("Saves photo data on the created Person")
    func completeSavesPhoto() async throws {
        let ctx = TestSupport.makeContext()
        let reloader = MockWidgetReloader()
        let registrar = MockShortcutRegistrar()

        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 100, height: 100), format: format)
        let image = renderer.image { context in
            UIColor.red.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 100, height: 100))
        }

        let input = OnboardingService.Input(
            name: "Bob", photo: image, gender: .male,
            startDate: .now, firstLike: ""
        )
        await OnboardingService.complete(input, modelContext: ctx, widgetReloader: reloader, shortcutRegistrar: registrar)

        let person = try #require(try ctx.fetch(FetchDescriptor<Person>()).first)
        #expect(person.photoData != nil)
    }

    @Test("Auto-creates a recurring Anniversary ImportantDate")
    func completeCreatesAnniversary() async throws {
        let ctx = TestSupport.makeContext()
        let reloader = MockWidgetReloader()
        let registrar = MockShortcutRegistrar()
        let date = TestFixtures.sampleRelationshipStart

        let input = OnboardingService.Input(
            name: "Carol", photo: nil, gender: .other,
            startDate: date, firstLike: ""
        )
        await OnboardingService.complete(input, modelContext: ctx, widgetReloader: reloader, shortcutRegistrar: registrar)

        let anniversary = try #require(try ctx.fetch(FetchDescriptor<ImportantDate>()).first)
        #expect(anniversary.title == "Our Anniversary")
        #expect(anniversary.date == date)
        #expect(anniversary.isRecurring == true)
        #expect(anniversary.predefinedCategory == .anniversary)
        #expect(anniversary.person?.name == "Carol")
    }

    @Test("Creates first like item when provided")
    func completeCreatesFirstLike() async throws {
        let ctx = TestSupport.makeContext()
        let reloader = MockWidgetReloader()
        let registrar = MockShortcutRegistrar()

        let input = OnboardingService.Input(
            name: "Dana", photo: nil, gender: .female,
            startDate: .now, firstLike: "Sunflowers"
        )
        await OnboardingService.complete(input, modelContext: ctx, widgetReloader: reloader, shortcutRegistrar: registrar)

        let like = try #require(try ctx.fetch(FetchDescriptor<LikeDislikeItem>()).first)
        #expect(like.name == "Sunflowers")
        #expect(like.kind == .like)
        #expect(like.predefinedCategory == .other)
        #expect(like.person?.name == "Dana")
    }

    @Test("Skipping optional steps completes without photo or like")
    func completeWithoutOptionalFields() async throws {
        let ctx = TestSupport.makeContext()
        let reloader = MockWidgetReloader()
        let registrar = MockShortcutRegistrar()

        let input = OnboardingService.Input(
            name: "Eve", photo: nil, gender: .male,
            startDate: .now, firstLike: ""
        )
        await OnboardingService.complete(input, modelContext: ctx, widgetReloader: reloader, shortcutRegistrar: registrar)

        let person = try #require(try ctx.fetch(FetchDescriptor<Person>()).first)
        #expect(person.photoData == nil)

        let likes = try ctx.fetch(FetchDescriptor<LikeDislikeItem>())
        #expect(likes.isEmpty)

        let dates = try ctx.fetch(FetchDescriptor<ImportantDate>())
        #expect(dates.count == 1)
    }

    @Test("Whitespace-only like is not saved")
    func completeIgnoresWhitespaceLike() async throws {
        let ctx = TestSupport.makeContext()
        let reloader = MockWidgetReloader()
        let registrar = MockShortcutRegistrar()

        let input = OnboardingService.Input(
            name: "Frank", photo: nil, gender: .other,
            startDate: .now, firstLike: "   "
        )
        await OnboardingService.complete(input, modelContext: ctx, widgetReloader: reloader, shortcutRegistrar: registrar)

        let likes = try ctx.fetch(FetchDescriptor<LikeDislikeItem>())
        #expect(likes.isEmpty)
    }

    @Test("Widget data syncs after onboarding completes")
    func completeSyncsWidgetData() async {
        let ctx = TestSupport.makeContext()
        let reloader = MockWidgetReloader()
        let registrar = MockShortcutRegistrar()

        let input = OnboardingService.Input(
            name: "Grace", photo: nil, gender: .female,
            startDate: .now, firstLike: ""
        )
        await OnboardingService.complete(input, modelContext: ctx, widgetReloader: reloader, shortcutRegistrar: registrar)

        #expect(reloader.reloadCallCount == 1)
    }

    @Test("Quick actions register after onboarding completes")
    func completeRegistersQuickActions() async {
        let ctx = TestSupport.makeContext()
        let reloader = MockWidgetReloader()
        let registrar = MockShortcutRegistrar()

        let input = OnboardingService.Input(
            name: "Hank", photo: nil, gender: .male,
            startDate: .now, firstLike: ""
        )
        await OnboardingService.complete(input, modelContext: ctx, widgetReloader: reloader, shortcutRegistrar: registrar)

        let items = registrar.items ?? []
        #expect(items.count == 2)
    }
}
