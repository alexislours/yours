import Foundation
import SwiftData
import Testing
@testable import yours

@Suite("FoodOrderService", .tags(.services, .foodOrders))
@MainActor
struct FoodOrderServiceTests {
    // MARK: - Creating with Predefined Category

    @Suite("Creating with predefined category")
    @MainActor
    struct CreatePredefined {
        @Test("Sets place, order, note, and predefined category")
        func setsCorrectFields() {
            let ctx = TestSupport.makeContext()
            let person = TestSupport.seedPerson(in: ctx)

            FoodOrderService.save(
                .init(
                    existing: nil,
                    place: "  Starbucks  ",
                    order: " Oat milk latte ",
                    note: "Extra shot",
                    useCustomCategory: false,
                    selectedPredefined: .coffee,
                    selectedCustomCategory: nil,
                    person: person
                ),
                in: ctx
            )

            let items = person.foodOrderItems ?? []
            #expect(items.count == 1)
            let item = items[0]
            #expect(item.place == "Starbucks")
            #expect(item.order == "Oat milk latte")
            #expect(item.note == "Extra shot")
            #expect(item.predefinedCategory == .coffee)
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
            let category = FoodOrderCategory(name: "Brunch", sfSymbol: "sun.max.fill", colorName: "amber")
            ctx.insert(category)

            FoodOrderService.save(
                .init(
                    existing: nil,
                    place: "Cafe",
                    order: "Eggs Benedict",
                    note: "",
                    useCustomCategory: true,
                    selectedPredefined: .breakfast,
                    selectedCustomCategory: category,
                    person: person
                ),
                in: ctx
            )

            let item = (person.foodOrderItems ?? []).first
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

            let item = FoodOrderItem(
                place: "Old Place",
                order: "Old Order",
                predefinedCategory: .lunch,
                person: person
            )
            ctx.insert(item)
            try ctx.save()

            FoodOrderService.save(
                .init(
                    existing: item,
                    place: "New Place",
                    order: "New Order",
                    note: "Updated",
                    useCustomCategory: false,
                    selectedPredefined: .lunch,
                    selectedCustomCategory: nil,
                    person: person
                ),
                in: ctx
            )

            #expect(item.place == "New Place")
            #expect(item.order == "New Order")
            #expect(item.note == "Updated")
            #expect(item.predefinedCategory == .lunch)
            #expect(item.customCategory == nil)
        }
    }

    // MARK: - Validation

    @Suite("Validation")
    @MainActor
    struct Validation {
        @Test("Blank place is rejected")
        func blankPlaceRejected() {
            let ctx = TestSupport.makeContext()
            let person = TestSupport.seedPerson(in: ctx)

            FoodOrderService.save(
                .init(
                    existing: nil,
                    place: "   ",
                    order: "Latte",
                    note: "",
                    useCustomCategory: false,
                    selectedPredefined: .coffee,
                    selectedCustomCategory: nil,
                    person: person
                ),
                in: ctx
            )

            #expect((person.foodOrderItems ?? []).isEmpty)
        }

        @Test("Blank order is rejected")
        func blankOrderRejected() {
            let ctx = TestSupport.makeContext()
            let person = TestSupport.seedPerson(in: ctx)

            FoodOrderService.save(
                .init(
                    existing: nil,
                    place: "Cafe",
                    order: "  ",
                    note: "",
                    useCustomCategory: false,
                    selectedPredefined: .coffee,
                    selectedCustomCategory: nil,
                    person: person
                ),
                in: ctx
            )

            #expect((person.foodOrderItems ?? []).isEmpty)
        }
    }

    // MARK: - Sort Order

    @Suite("Sort order")
    @MainActor
    struct SortOrder {
        @Test("First item in a category gets sortOrder 0")
        func firstItemSortOrderZero() {
            let ctx = TestSupport.makeContext()
            let person = TestSupport.seedPerson(in: ctx)

            FoodOrderService.save(
                .init(
                    existing: nil,
                    place: "Starbucks",
                    order: "Latte",
                    note: "",
                    useCustomCategory: false,
                    selectedPredefined: .coffee,
                    selectedCustomCategory: nil,
                    person: person
                ),
                in: ctx
            )

            let item = (person.foodOrderItems ?? []).first
            #expect(item?.sortOrder == 0)
        }

        @Test("Subsequent items increment sortOrder within same category")
        func incrementsWithinCategory() {
            let ctx = TestSupport.makeContext()
            let person = TestSupport.seedPerson(in: ctx)

            for order in ["Latte", "Cappuccino", "Espresso"] {
                FoodOrderService.save(
                    .init(
                        existing: nil,
                        place: "Starbucks",
                        order: order,
                        note: "",
                        useCustomCategory: false,
                        selectedPredefined: .coffee,
                        selectedCustomCategory: nil,
                        person: person
                    ),
                    in: ctx
                )
            }

            let items = (person.foodOrderItems ?? []).sorted { $0.sortOrder < $1.sortOrder }
            #expect(items.count == 3)
            #expect(items[0].sortOrder == 0)
            #expect(items[1].sortOrder == 1)
            #expect(items[2].sortOrder == 2)
        }

        @Test("Different categories maintain independent sort orders")
        func independentPerCategory() {
            let ctx = TestSupport.makeContext()
            let person = TestSupport.seedPerson(in: ctx)

            FoodOrderService.save(
                .init(
                    existing: nil,
                    place: "Starbucks",
                    order: "Latte",
                    note: "",
                    useCustomCategory: false,
                    selectedPredefined: .coffee,
                    selectedCustomCategory: nil,
                    person: person
                ),
                in: ctx
            )

            FoodOrderService.save(
                .init(
                    existing: nil,
                    place: "Chipotle",
                    order: "Bowl",
                    note: "",
                    useCustomCategory: false,
                    selectedPredefined: .lunch,
                    selectedCustomCategory: nil,
                    person: person
                ),
                in: ctx
            )

            let items = person.foodOrderItems ?? []
            let coffeeItem = items.first { $0.predefinedCategory == .coffee }
            let lunchItem = items.first { $0.predefinedCategory == .lunch }
            #expect(coffeeItem?.sortOrder == 0)
            #expect(lunchItem?.sortOrder == 0)
        }
    }
}
