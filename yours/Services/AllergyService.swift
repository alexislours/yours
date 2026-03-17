import Foundation
import SwiftData

enum AllergyService {
    struct SaveInput {
        let existing: AllergyItem?
        let name: String
        let note: String
        let useCustomCategory: Bool
        let selectedPredefined: AllergyPredefinedCategory
        let selectedCustomCategory: AllergyCategory?
        let person: Person
    }

    static func save(_ input: SaveInput, in context: ModelContext) {
        guard let trimmedName = input.name.nonBlank else { return }

        if let existing = input.existing {
            existing.name = trimmedName
            existing.note = input.note.nonBlank
            existing.updatedAt = .now
            existing.applyCategorySelection(
                useCustom: input.useCustomCategory,
                custom: input.selectedCustomCategory,
                predefined: input.selectedPredefined,
                fallback: .other
            )
        } else {
            let cat = AllergyItem.resolveCategory(
                useCustom: input.useCustomCategory,
                custom: input.selectedCustomCategory,
                predefined: input.selectedPredefined,
                fallback: .other
            )
            let item = AllergyItem(
                name: trimmedName,
                note: input.note.nonBlank,
                predefinedCategory: cat.predefined,
                customCategory: cat.custom,
                person: input.person
            )
            context.insert(item)
        }
    }
}
