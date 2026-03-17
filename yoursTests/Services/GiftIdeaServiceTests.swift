import Foundation
import SwiftData
import Testing
@testable import yours

@Suite("GiftIdeaService", .tags(.services, .giftIdeas))
@MainActor
struct GiftIdeaServiceTests {
    // MARK: - Creating with Predefined Category

    @Suite("Creating with predefined category")
    @MainActor
    struct CreatePredefined {
        @Test("Sets title, note, price, URL, and predefined category")
        func setsCorrectFields() {
            let ctx = TestSupport.makeContext()
            let person = TestSupport.seedPerson(in: ctx)

            GiftIdeaService.save(
                .init(
                    existing: nil,
                    title: "  Watch  ",
                    note: "Leather band",
                    price: 299.99,
                    urlString: "example.com/watch",
                    useCustomCategory: false,
                    selectedPredefined: .birthday,
                    selectedCustomCategory: nil,
                    linkedDate: nil,
                    person: person
                ),
                in: ctx
            )

            let gifts = (person.giftIdeas ?? [])
            #expect(gifts.count == 1)
            let gift = gifts[0]
            #expect(gift.title == "Watch")
            #expect(gift.note == "Leather band")
            #expect(gift.price == 299.99)
            #expect(gift.urlString == "example.com/watch")
            #expect(gift.predefinedCategory == .birthday)
            #expect(gift.customCategory == nil)
        }

        @Test("Links an ImportantDate when provided")
        func linksDate() {
            let ctx = TestSupport.makeContext()
            let person = TestSupport.seedPerson(in: ctx)
            let date = TestSupport.seedImportantDate(
                in: ctx, title: "Birthday",
                date: TestFixtures.futureDate(daysFromNow: 30),
                person: person
            )

            GiftIdeaService.save(
                .init(
                    existing: nil,
                    title: "Book",
                    note: "",
                    price: nil,
                    urlString: "",
                    useCustomCategory: false,
                    selectedPredefined: .birthday,
                    selectedCustomCategory: nil,
                    linkedDate: date,
                    person: person
                ),
                in: ctx
            )

            let gift = (person.giftIdeas ?? []).first
            #expect(gift?.linkedDate === date)
        }
    }

    // MARK: - Creating with Custom Category

    @Suite("Creating with custom category")
    @MainActor
    struct CreateCustom {
        @Test("Sets custom category and falls back predefined to justBecause")
        func setsCustomCategory() {
            let ctx = TestSupport.makeContext()
            let person = TestSupport.seedPerson(in: ctx)
            let category = GiftCategory(name: "Housewarming", sfSymbol: "house.fill", colorName: "sage")
            ctx.insert(category)

            GiftIdeaService.save(
                .init(
                    existing: nil,
                    title: "Candle Set",
                    note: "",
                    price: nil,
                    urlString: "",
                    useCustomCategory: true,
                    selectedPredefined: .birthday,
                    selectedCustomCategory: category,
                    linkedDate: nil,
                    person: person
                ),
                in: ctx
            )

            let gift = (person.giftIdeas ?? []).first
            #expect(gift?.customCategory === category)
            #expect(gift?.predefinedCategory == .justBecause)
        }
    }

    // MARK: - Updating

    @Suite("Updating an existing item")
    @MainActor
    struct Update {
        @Test("Preserves predefined category when not switching to custom")
        func preservesPredefined() {
            let ctx = TestSupport.makeContext()
            let person = TestSupport.seedPerson(in: ctx)
            let gift = TestSupport.seedGiftIdea(
                in: ctx, title: "Old Title",
                predefinedCategory: .anniversary,
                person: person
            )

            GiftIdeaService.save(
                .init(
                    existing: gift,
                    title: "New Title",
                    note: "",
                    price: nil,
                    urlString: "",
                    useCustomCategory: false,
                    selectedPredefined: .anniversary,
                    selectedCustomCategory: nil,
                    linkedDate: nil,
                    person: person
                ),
                in: ctx
            )

            #expect(gift.title == "New Title")
            #expect(gift.predefinedCategory == .anniversary)
            #expect(gift.customCategory == nil)
        }

        @Test("Switches from predefined to custom category")
        func switchesToCustom() {
            let ctx = TestSupport.makeContext()
            let person = TestSupport.seedPerson(in: ctx)
            let gift = TestSupport.seedGiftIdea(
                in: ctx, title: "Gift",
                predefinedCategory: .birthday,
                person: person
            )
            let category = GiftCategory(name: "Graduation", sfSymbol: "graduationcap", colorName: "dusk")
            ctx.insert(category)

            GiftIdeaService.save(
                .init(
                    existing: gift,
                    title: "Gift",
                    note: "",
                    price: nil,
                    urlString: "",
                    useCustomCategory: true,
                    selectedPredefined: .birthday,
                    selectedCustomCategory: category,
                    linkedDate: nil,
                    person: person
                ),
                in: ctx
            )

            #expect(gift.customCategory === category)
            #expect(gift.predefinedCategory == .justBecause)
        }

        @Test("Switches from custom back to predefined category")
        func switchesBackToPredefined() throws {
            let ctx = TestSupport.makeContext()
            let person = TestSupport.seedPerson(in: ctx)
            let category = GiftCategory(name: "Custom", sfSymbol: "star", colorName: "amber")
            ctx.insert(category)

            let gift = GiftIdea(
                title: "Gift",
                predefinedCategory: .justBecause,
                customCategory: category,
                person: person
            )
            ctx.insert(gift)
            try ctx.save()

            GiftIdeaService.save(
                .init(
                    existing: gift,
                    title: "Gift",
                    note: "",
                    price: nil,
                    urlString: "",
                    useCustomCategory: false,
                    selectedPredefined: .holiday,
                    selectedCustomCategory: nil,
                    linkedDate: nil,
                    person: person
                ),
                in: ctx
            )

            #expect(gift.customCategory == nil)
            #expect(gift.predefinedCategory == .holiday)
        }
    }

    // MARK: - Validation

    @Suite("Validation")
    @MainActor
    struct Validation {
        @Test("Blank title is rejected")
        func blankTitleRejected() {
            let ctx = TestSupport.makeContext()
            let person = TestSupport.seedPerson(in: ctx)

            GiftIdeaService.save(
                .init(
                    existing: nil,
                    title: "   ",
                    note: "",
                    price: nil,
                    urlString: "",
                    useCustomCategory: false,
                    selectedPredefined: .justBecause,
                    selectedCustomCategory: nil,
                    linkedDate: nil,
                    person: person
                ),
                in: ctx
            )

            #expect((person.giftIdeas ?? []).isEmpty)
        }

        @Test("Empty title is rejected")
        func emptyTitleRejected() {
            let ctx = TestSupport.makeContext()
            let person = TestSupport.seedPerson(in: ctx)

            GiftIdeaService.save(
                .init(
                    existing: nil,
                    title: "",
                    note: "",
                    price: nil,
                    urlString: "",
                    useCustomCategory: false,
                    selectedPredefined: .justBecause,
                    selectedCustomCategory: nil,
                    linkedDate: nil,
                    person: person
                ),
                in: ctx
            )

            #expect((person.giftIdeas ?? []).isEmpty)
        }
    }
}
