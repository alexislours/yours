import Foundation
import SwiftData

enum ImportantDateService {
    struct SaveInput {
        let existing: ImportantDate?
        let title: String
        let date: Date
        let note: String
        let recurrenceFrequency: RecurrenceFrequency
        let reminderEnabled: Bool
        let reminderDaysBefore: Int
        let useCustomCategory: Bool
        let selectedPredefined: ImportantDatePredefinedCategory
        let selectedCustomCategory: DateCategory?
        let person: Person
    }

    static func save(_ input: SaveInput, in context: ModelContext) {
        guard let trimmedTitle = input.title.nonBlank else { return }

        if let existing = input.existing {
            existing.title = trimmedTitle
            existing.date = input.date
            existing.note = input.note.nonBlank
            existing.recurrenceFrequency = input.recurrenceFrequency
            existing.reminderEnabled = input.reminderEnabled
            existing.reminderDaysBefore = input.reminderDaysBefore
            existing.updatedAt = .now
            if input.useCustomCategory {
                existing.customCategory = input.selectedCustomCategory
                existing.predefinedCategory = .other
            } else {
                existing.customCategory = nil
                existing.predefinedCategory = input.selectedPredefined
            }
        } else {
            let newDate = ImportantDate(
                title: trimmedTitle,
                date: input.date,
                note: input.note.nonBlank,
                recurrenceFrequency: input.recurrenceFrequency,
                predefinedCategory: input.useCustomCategory ? .other : input.selectedPredefined,
                customCategory: input.useCustomCategory ? input.selectedCustomCategory : nil,
                reminderEnabled: input.reminderEnabled,
                reminderDaysBefore: input.reminderDaysBefore,
                person: input.person
            )
            context.insert(newDate)
        }
    }
}
