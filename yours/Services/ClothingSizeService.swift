import Foundation
import SwiftData

enum ClothingSizeService {
    struct SaveInput {
        let existing: ClothingSizeItem?
        let size: String
        let note: String
        let useCustomCategory: Bool
        let selectedPredefined: ClothingSizePredefinedCategory
        let selectedCustomCategory: ClothingSizeCategory?
        let person: Person
    }

    static func save(_ input: SaveInput, in context: ModelContext) {
        guard let trimmedSize = input.size.nonBlank else { return }

        if let existing = input.existing {
            existing.size = trimmedSize
            existing.note = input.note.nonBlank
            existing.updatedAt = .now
            existing.applyCategorySelection(
                useCustom: input.useCustomCategory,
                custom: input.selectedCustomCategory,
                predefined: input.selectedPredefined,
                fallback: .other
            )
        } else {
            let cat = ClothingSizeItem.resolveCategory(
                useCustom: input.useCustomCategory,
                custom: input.selectedCustomCategory,
                predefined: input.selectedPredefined,
                fallback: .other
            )
            let item = ClothingSizeItem(
                size: trimmedSize,
                note: input.note.nonBlank,
                predefinedCategory: cat.predefined,
                customCategory: cat.custom,
                person: input.person
            )
            context.insert(item)
        }
    }
}
