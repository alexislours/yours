import Foundation
import SwiftData

enum BirthdayService {
    static func setBirthday(
        date: Date,
        person: Person,
        in context: ModelContext
    ) {
        person.birthday = date

        if let existing = existingBirthdayDate(for: person) {
            existing.date = date
            existing.updatedAt = .now
        } else {
            let birthdayDate = ImportantDate(
                // swiftlint:disable:next line_length
                title: String(localized: "\(person.firstName)'s Birthday", comment: "Birthday service: title for auto-created birthday important date"),
                date: date,
                recurrenceFrequency: .yearly,
                predefinedCategory: .birthday,
                person: person
            )
            context.insert(birthdayDate)
        }
    }

    static func removeBirthday(
        person: Person,
        in context: ModelContext
    ) {
        person.birthday = nil

        if let existing = existingBirthdayDate(for: person) {
            context.delete(existing)
        }
    }

    private static func existingBirthdayDate(for person: Person) -> ImportantDate? {
        (person.importantDates ?? []).first {
            $0.predefinedCategory == .birthday && $0.customCategory == nil
        }
    }
}
