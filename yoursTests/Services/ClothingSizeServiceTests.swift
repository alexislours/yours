import Foundation
import SwiftData
import Testing
@testable import yours

@Suite("ClothingSizeService", .tags(.services, .clothingSizes))
@MainActor
struct ClothingSizeServiceTests {
    // MARK: - Creating with Predefined Category

    @Suite("Creating with predefined category")
    @MainActor
    struct CreatePredefined {
        @Test("Sets size, note, and predefined category")
        func setsCorrectFields() {
            let ctx = TestSupport.makeContext()
            let person = TestSupport.seedPerson(in: ctx)

            ClothingSizeService.save(
                .init(
                    existing: nil,
                    size: "  Medium  ",
                    note: "Prefers loose fit",
                    useCustomCategory: false,
                    selectedPredefined: .tops,
                    selectedCustomCategory: nil,
                    person: person
                ),
                in: ctx
            )

            let items = person.clothingSizeItems ?? []
            #expect(items.count == 1)
            let item = items[0]
            #expect(item.size == "Medium")
            #expect(item.note == "Prefers loose fit")
            #expect(item.predefinedCategory == .tops)
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
            let category = ClothingSizeCategory(name: "Swimwear", sfSymbol: "sun.max", colorName: "sage")
            ctx.insert(category)

            ClothingSizeService.save(
                .init(
                    existing: nil,
                    size: "Large",
                    note: "",
                    useCustomCategory: true,
                    selectedPredefined: .tops,
                    selectedCustomCategory: category,
                    person: person
                ),
                in: ctx
            )

            let item = (person.clothingSizeItems ?? []).first
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

            let item = ClothingSizeItem(
                size: "10",
                predefinedCategory: .shoes,
                person: person
            )
            ctx.insert(item)
            try ctx.save()

            ClothingSizeService.save(
                .init(
                    existing: item,
                    size: "10.5",
                    note: "Wide fit",
                    useCustomCategory: false,
                    selectedPredefined: .shoes,
                    selectedCustomCategory: nil,
                    person: person
                ),
                in: ctx
            )

            #expect(item.size == "10.5")
            #expect(item.note == "Wide fit")
            #expect(item.predefinedCategory == .shoes)
            #expect(item.customCategory == nil)
        }
    }

    // MARK: - Validation

    @Suite("Validation")
    @MainActor
    struct Validation {
        @Test("Blank size is rejected")
        func blankSizeRejected() {
            let ctx = TestSupport.makeContext()
            let person = TestSupport.seedPerson(in: ctx)

            ClothingSizeService.save(
                .init(
                    existing: nil,
                    size: "   ",
                    note: "",
                    useCustomCategory: false,
                    selectedPredefined: .other,
                    selectedCustomCategory: nil,
                    person: person
                ),
                in: ctx
            )

            #expect((person.clothingSizeItems ?? []).isEmpty)
        }
    }
}
