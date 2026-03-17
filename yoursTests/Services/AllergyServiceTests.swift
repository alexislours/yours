import Foundation
import SwiftData
import Testing
@testable import yours

@Suite("AllergyService", .tags(.services, .allergies))
@MainActor
struct AllergyServiceTests {
    // MARK: - Creating with Predefined Category

    @Suite("Creating with predefined category")
    @MainActor
    struct CreatePredefined {
        @Test("Sets name, note, and predefined category")
        func setsCorrectFields() {
            let ctx = TestSupport.makeContext()
            let person = TestSupport.seedPerson(in: ctx)

            AllergyService.save(
                .init(
                    existing: nil,
                    name: "  Peanuts  ",
                    note: "Severe reaction",
                    useCustomCategory: false,
                    selectedPredefined: .food,
                    selectedCustomCategory: nil,
                    person: person
                ),
                in: ctx
            )

            let items = person.allergyItems ?? []
            #expect(items.count == 1)
            let item = items[0]
            #expect(item.name == "Peanuts")
            #expect(item.note == "Severe reaction")
            #expect(item.predefinedCategory == .food)
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
            let category = AllergyCategory(name: "Skincare", sfSymbol: "drop.fill", colorName: "rose")
            ctx.insert(category)

            AllergyService.save(
                .init(
                    existing: nil,
                    name: "Retinol",
                    note: "",
                    useCustomCategory: true,
                    selectedPredefined: .food,
                    selectedCustomCategory: category,
                    person: person
                ),
                in: ctx
            )

            let item = (person.allergyItems ?? []).first
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

            let item = AllergyItem(
                name: "Penicillin",
                predefinedCategory: .medication,
                person: person
            )
            ctx.insert(item)
            try ctx.save()

            AllergyService.save(
                .init(
                    existing: item,
                    name: "Amoxicillin",
                    note: "Causes rash",
                    useCustomCategory: false,
                    selectedPredefined: .medication,
                    selectedCustomCategory: nil,
                    person: person
                ),
                in: ctx
            )

            #expect(item.name == "Amoxicillin")
            #expect(item.note == "Causes rash")
            #expect(item.predefinedCategory == .medication)
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

            AllergyService.save(
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

            #expect((person.allergyItems ?? []).isEmpty)
        }
    }
}
