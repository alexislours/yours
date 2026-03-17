import Foundation
import SwiftData
import Testing
@testable import yours

@Suite("ImportantDateService", .tags(.services, .importantDates))
@MainActor
struct ImportantDateServiceTests {
    // MARK: - Creating with Predefined Category

    @Suite("Creating with predefined category")
    @MainActor
    struct CreatePredefined {
        @Test("Sets all fields correctly")
        func setsCorrectFields() {
            let ctx = TestSupport.makeContext()
            let person = TestSupport.seedPerson(in: ctx)
            let eventDate = TestFixtures.futureDate(daysFromNow: 30)

            ImportantDateService.save(
                .init(
                    existing: nil,
                    title: "  Anniversary  ",
                    date: eventDate,
                    note: "First year",
                    recurrenceFrequency: .yearly,
                    reminderEnabled: true,
                    reminderDaysBefore: 7,
                    useCustomCategory: false,
                    selectedPredefined: .anniversary,
                    selectedCustomCategory: nil,
                    person: person
                ),
                in: ctx
            )

            let dates = person.importantDates ?? []
            #expect(dates.count == 1)
            let date = dates[0]
            #expect(date.title == "Anniversary")
            #expect(date.date == eventDate)
            #expect(date.note == "First year")
            #expect(date.isRecurring == true)
            #expect(date.reminderEnabled == true)
            #expect(date.reminderDaysBefore == 7)
            #expect(date.predefinedCategory == .anniversary)
            #expect(date.customCategory == nil)
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
            let category = DateCategory(name: "Date Night", sfSymbol: "heart.fill", colorName: "rose")
            ctx.insert(category)

            ImportantDateService.save(
                .init(
                    existing: nil,
                    title: "Restaurant Reservation",
                    date: TestFixtures.futureDate(daysFromNow: 5),
                    note: "",
                    recurrenceFrequency: .never,
                    reminderEnabled: false,
                    reminderDaysBefore: 1,
                    useCustomCategory: true,
                    selectedPredefined: .anniversary,
                    selectedCustomCategory: category,
                    person: person
                ),
                in: ctx
            )

            let date = (person.importantDates ?? []).first
            #expect(date?.customCategory === category)
            #expect(date?.predefinedCategory == .other)
        }
    }

    // MARK: - Updating

    @Suite("Updating an existing item")
    @MainActor
    struct Update {
        @Test("Preserves category when not switching")
        func preservesCategory() {
            let ctx = TestSupport.makeContext()
            let person = TestSupport.seedPerson(in: ctx)
            let existing = TestSupport.seedImportantDate(
                in: ctx, title: "Old",
                date: TestFixtures.referenceDate,
                predefinedCategory: .holiday,
                person: person
            )

            let newDate = TestFixtures.futureDate(daysFromNow: 60)
            ImportantDateService.save(
                .init(
                    existing: existing,
                    title: "New Title",
                    date: newDate,
                    note: "Updated",
                    recurrenceFrequency: .yearly,
                    reminderEnabled: true,
                    reminderDaysBefore: 3,
                    useCustomCategory: false,
                    selectedPredefined: .holiday,
                    selectedCustomCategory: nil,
                    person: person
                ),
                in: ctx
            )

            #expect(existing.title == "New Title")
            #expect(existing.date == newDate)
            #expect(existing.note == "Updated")
            #expect(existing.isRecurring == true)
            #expect(existing.reminderEnabled == true)
            #expect(existing.reminderDaysBefore == 3)
            #expect(existing.predefinedCategory == .holiday)
            #expect(existing.customCategory == nil)
        }

        @Test("Changes from predefined to custom category")
        func switchesToCustom() {
            let ctx = TestSupport.makeContext()
            let person = TestSupport.seedPerson(in: ctx)
            let existing = TestSupport.seedImportantDate(
                in: ctx, title: "Event",
                date: TestFixtures.referenceDate,
                predefinedCategory: .anniversary,
                person: person
            )
            let category = DateCategory(name: "Travel", sfSymbol: "airplane", colorName: "sage")
            ctx.insert(category)

            ImportantDateService.save(
                .init(
                    existing: existing,
                    title: "Event",
                    date: TestFixtures.referenceDate,
                    note: "",
                    recurrenceFrequency: .never,
                    reminderEnabled: false,
                    reminderDaysBefore: 1,
                    useCustomCategory: true,
                    selectedPredefined: .anniversary,
                    selectedCustomCategory: category,
                    person: person
                ),
                in: ctx
            )

            #expect(existing.customCategory === category)
            #expect(existing.predefinedCategory == .other)
        }
    }

    // MARK: - Validation

    @Suite("Validation")
    @MainActor
    struct Validation {
        @Test("Blank title is rejected")
        func blankTitleRejected() {
            let ctx = TestSupport.makeContext()
            let person = TestSupport.seedPerson(in: ctx)

            ImportantDateService.save(
                .init(
                    existing: nil,
                    title: "   ",
                    date: TestFixtures.referenceDate,
                    note: "",
                    recurrenceFrequency: .never,
                    reminderEnabled: false,
                    reminderDaysBefore: 1,
                    useCustomCategory: false,
                    selectedPredefined: .other,
                    selectedCustomCategory: nil,
                    person: person
                ),
                in: ctx
            )

            #expect((person.importantDates ?? []).isEmpty)
        }
    }
}
