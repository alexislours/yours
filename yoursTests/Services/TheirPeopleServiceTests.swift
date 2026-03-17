import Foundation
import SwiftData
import Testing
@testable import yours

@Suite("TheirPeopleService", .tags(.services, .theirPeople))
@MainActor
struct TheirPeopleServiceTests {
    // MARK: - Creating with Predefined Category

    @Suite("Creating with predefined category")
    @MainActor
    struct CreatePredefined {
        @Test("Sets name, note, and predefined category")
        func setsCorrectFields() {
            let ctx = TestSupport.makeContext()
            let person = TestSupport.seedPerson(in: ctx)

            TheirPeopleService.save(
                .init(
                    existing: nil,
                    name: "  Sarah  ",
                    note: "Lives in Portland",
                    useCustomCategory: false,
                    selectedPredefined: .friend,
                    selectedCustomCategory: nil,
                    person: person
                ),
                in: ctx
            )

            let items = person.theirPeopleItems ?? []
            #expect(items.count == 1)
            let item = items[0]
            #expect(item.name == "Sarah")
            #expect(item.note == "Lives in Portland")
            #expect(item.predefinedCategory == .friend)
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
            let category = TheirPeopleCategory(name: "Roommate", sfSymbol: "house.fill", colorName: "sage")
            ctx.insert(category)

            TheirPeopleService.save(
                .init(
                    existing: nil,
                    name: "Alex",
                    note: "",
                    useCustomCategory: true,
                    selectedPredefined: .friend,
                    selectedCustomCategory: category,
                    person: person
                ),
                in: ctx
            )

            let item = (person.theirPeopleItems ?? []).first
            #expect(item?.customCategory === category)
            #expect(item?.predefinedCategory == .other)
        }
    }

    // MARK: - Updating

    @Suite("Updating an existing item")
    @MainActor
    struct Update {
        @Test("Preserves category when not switching")
        func preservesCategory() throws {
            let ctx = TestSupport.makeContext()
            let person = TestSupport.seedPerson(in: ctx)

            let item = TheirPeopleItem(
                name: "Mom",
                predefinedCategory: .mom,
                person: person
            )
            ctx.insert(item)
            try ctx.save()

            TheirPeopleService.save(
                .init(
                    existing: item,
                    name: "Mom (Linda)",
                    note: "Birthday in March",
                    useCustomCategory: false,
                    selectedPredefined: .mom,
                    selectedCustomCategory: nil,
                    person: person
                ),
                in: ctx
            )

            #expect(item.name == "Mom (Linda)")
            #expect(item.note == "Birthday in March")
            #expect(item.predefinedCategory == .mom)
            #expect(item.customCategory == nil)
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

            TheirPeopleService.save(
                .init(
                    existing: nil,
                    name: "   ",
                    note: "",
                    useCustomCategory: false,
                    selectedPredefined: .other,
                    selectedCustomCategory: nil,
                    person: person
                ),
                in: ctx
            )

            #expect((person.theirPeopleItems ?? []).isEmpty)
        }
    }
}
