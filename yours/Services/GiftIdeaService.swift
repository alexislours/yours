import Foundation
import SwiftData

enum GiftIdeaService {
    struct SaveInput {
        let existing: GiftIdea?
        let title: String
        let note: String
        let price: Decimal?
        let urlString: String
        let useCustomCategory: Bool
        let selectedPredefined: GiftOccasion
        let selectedCustomCategory: GiftCategory?
        let linkedDate: ImportantDate?
        let person: Person
    }

    static func save(_ input: SaveInput, in context: ModelContext) {
        guard let trimmedTitle = input.title.nonBlank else { return }

        if let existing = input.existing {
            existing.title = trimmedTitle
            existing.note = input.note.nonBlank
            existing.price = input.price
            existing.urlString = input.urlString.nonBlank
            existing.linkedDate = input.linkedDate
            existing.updatedAt = .now
            if input.useCustomCategory {
                existing.customCategory = input.selectedCustomCategory
                existing.predefinedCategory = .justBecause
            } else {
                existing.customCategory = nil
                existing.predefinedCategory = input.selectedPredefined
            }
        } else {
            let idea = GiftIdea(
                title: trimmedTitle,
                note: input.note.nonBlank,
                price: input.price,
                urlString: input.urlString.nonBlank,
                predefinedCategory: input.useCustomCategory ? .justBecause : input.selectedPredefined,
                customCategory: input.useCustomCategory ? input.selectedCustomCategory : nil,
                linkedDate: input.linkedDate,
                person: input.person
            )
            context.insert(idea)
        }
    }
}
