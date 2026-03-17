import Foundation
import SwiftData

enum FoodOrderService {
    struct SaveInput {
        let existing: FoodOrderItem?
        let place: String
        let order: String
        let note: String
        let useCustomCategory: Bool
        let selectedPredefined: FoodOrderPredefinedCategory
        let selectedCustomCategory: FoodOrderCategory?
        let person: Person
    }

    static func save(_ input: SaveInput, in context: ModelContext) {
        guard let trimmedPlace = input.place.nonBlank,
              let trimmedOrder = input.order.nonBlank else { return }

        if let existing = input.existing {
            existing.place = trimmedPlace
            existing.order = trimmedOrder
            existing.note = input.note.nonBlank
            existing.updatedAt = .now
            existing.applyCategorySelection(
                useCustom: input.useCustomCategory,
                custom: input.selectedCustomCategory,
                predefined: input.selectedPredefined,
                fallback: .other
            )
        } else {
            // Calculate sort order: append to end of category
            let categoryKey = input.useCustomCategory ? "custom" : input.selectedPredefined.rawValue
            let existingInCategory = (input.person.foodOrderItems ?? []).filter { $0.categoryGroupKey == categoryKey }
            let maxSort = existingInCategory.map(\.sortOrder).max() ?? -1

            let cat = FoodOrderItem.resolveCategory(
                useCustom: input.useCustomCategory,
                custom: input.selectedCustomCategory,
                predefined: input.selectedPredefined,
                fallback: .other
            )
            let item = FoodOrderItem(
                place: trimmedPlace,
                order: trimmedOrder,
                note: input.note.nonBlank,
                predefinedCategory: cat.predefined,
                customCategory: cat.custom,
                sortOrder: maxSort + 1,
                person: input.person
            )
            context.insert(item)
        }
    }
}
