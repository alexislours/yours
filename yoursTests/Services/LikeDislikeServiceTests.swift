import Foundation
import SwiftData
import Testing
@testable import yours

@Suite("LikeDislikeService", .tags(.services, .likeDislikes))
@MainActor
struct LikeDislikeServiceTests {
    // MARK: - Creating with Predefined Category

    @Suite("Creating with predefined category")
    @MainActor
    struct CreatePredefined {
        @Test("Sets name, note, kind, and predefined category")
        func setsCorrectFields() {
            let ctx = TestSupport.makeContext()
            let person = TestSupport.seedPerson(in: ctx)

            LikeDislikeService.save(
                .init(
                    existing: nil,
                    name: "  Sushi  ",
                    note: "Especially salmon",
                    kind: .like,
                    useCustomCategory: false,
                    selectedPredefined: .foodDrinks,
                    selectedCustomCategory: nil,
                    person: person
                ),
                in: ctx
            )

            let items = person.likeDislikeItems ?? []
            #expect(items.count == 1)
            let item = items[0]
            #expect(item.name == "Sushi")
            #expect(item.note == "Especially salmon")
            #expect(item.kind == .like)
            #expect(item.predefinedCategory == .foodDrinks)
            #expect(item.customCategory == nil)
        }
    }

    // MARK: - Creating with Custom Category

    @Suite("Creating with custom category")
    @MainActor
    struct CreateCustom {
        @Test("Sets custom category and falls back predefined to other")
        func setsCustomCategory() {
            let ctx = TestSupport.makeContext()
            let person = TestSupport.seedPerson(in: ctx)
            let category = LikeDislikeCategory(name: "Games", sfSymbol: "gamecontroller", colorName: "dusk")
            ctx.insert(category)

            LikeDislikeService.save(
                .init(
                    existing: nil,
                    name: "Chess",
                    note: "",
                    kind: .like,
                    useCustomCategory: true,
                    selectedPredefined: .activitiesHobbies,
                    selectedCustomCategory: category,
                    person: person
                ),
                in: ctx
            )

            let item = (person.likeDislikeItems ?? []).first
            #expect(item?.customCategory === category)
            #expect(item?.predefinedCategory == .other)
        }
    }

    // MARK: - Updating

    @Suite("Updating an existing item")
    @MainActor
    struct Update {
        @Test("Preserves category when not switching")
        func preservesCategory() {
            let ctx = TestSupport.makeContext()
            let person = TestSupport.seedPerson(in: ctx)
            let item = TestSupport.seedLikeDislike(
                in: ctx, name: "Old",
                kind: .like,
                predefinedCategory: .music,
                person: person
            )

            LikeDislikeService.save(
                .init(
                    existing: item,
                    name: "Jazz",
                    note: "Smooth jazz",
                    kind: .like,
                    useCustomCategory: false,
                    selectedPredefined: .music,
                    selectedCustomCategory: nil,
                    person: person
                ),
                in: ctx
            )

            #expect(item.name == "Jazz")
            #expect(item.note == "Smooth jazz")
            #expect(item.predefinedCategory == .music)
            #expect(item.customCategory == nil)
        }

        @Test("Changes from predefined to custom category")
        func switchesToCustom() {
            let ctx = TestSupport.makeContext()
            let person = TestSupport.seedPerson(in: ctx)
            let item = TestSupport.seedLikeDislike(
                in: ctx, name: "Item",
                kind: .dislike,
                predefinedCategory: .foodDrinks,
                person: person
            )
            let category = LikeDislikeCategory(name: "Pet Peeves", sfSymbol: "xmark.circle", colorName: "clay")
            ctx.insert(category)

            LikeDislikeService.save(
                .init(
                    existing: item,
                    name: "Item",
                    note: "",
                    kind: .dislike,
                    useCustomCategory: true,
                    selectedPredefined: .foodDrinks,
                    selectedCustomCategory: category,
                    person: person
                ),
                in: ctx
            )

            #expect(item.customCategory === category)
            #expect(item.predefinedCategory == .other)
        }
    }

    // MARK: - Validation

    @Suite("Validation")
    @MainActor
    struct Validation {
        @Test("Blank name is rejected")
        func blankNameRejected() {
            let ctx = TestSupport.makeContext()
            let person = TestSupport.seedPerson(in: ctx)

            LikeDislikeService.save(
                .init(
                    existing: nil,
                    name: "   ",
                    note: "",
                    kind: .like,
                    useCustomCategory: false,
                    selectedPredefined: .other,
                    selectedCustomCategory: nil,
                    person: person
                ),
                in: ctx
            )

            #expect((person.likeDislikeItems ?? []).isEmpty)
        }
    }
}
