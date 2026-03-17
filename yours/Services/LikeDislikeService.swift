import Foundation
import SwiftData

enum LikeDislikeService {
    struct SaveInput {
        let existing: LikeDislikeItem?
        let name: String
        let note: String
        let kind: LikeDislikeItem.Kind
        let useCustomCategory: Bool
        let selectedPredefined: LikeDislikePredefinedCategory
        let selectedCustomCategory: LikeDislikeCategory?
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
            let cat = LikeDislikeItem.resolveCategory(
                useCustom: input.useCustomCategory,
                custom: input.selectedCustomCategory,
                predefined: input.selectedPredefined,
                fallback: .other
            )
            let item = LikeDislikeItem(
                name: trimmedName,
                note: input.note.nonBlank,
                kind: input.kind,
                predefinedCategory: cat.predefined,
                customCategory: cat.custom,
                person: input.person
            )
            context.insert(item)
        }
    }
}
