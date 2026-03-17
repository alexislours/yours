import Foundation
import SwiftData
import Testing
@testable import yours

@Suite("BirthdayService", .tags(.services, .birthdays))
@MainActor
struct BirthdayServiceTests {
    @Test("Setting a birthday creates an ImportantDate with the Birthday predefined category")
    func setBirthdayCreatesImportantDate() {
        let ctx = TestSupport.makeContext()
        let person = TestSupport.seedPerson(in: ctx, name: "Alice")

        BirthdayService.setBirthday(date: TestFixtures.sampleBirthday, person: person, in: ctx)

        let dates = person.importantDates ?? []
        let birthdayDate = dates.first { $0.predefinedCategory == .birthday }

        #expect(birthdayDate != nil)
        #expect(birthdayDate?.date == TestFixtures.sampleBirthday)
        #expect(birthdayDate?.predefinedCategory == .birthday)
        #expect(birthdayDate?.customCategory == nil)
        #expect(person.birthday == TestFixtures.sampleBirthday)
    }

    @Test("Setting a birthday when one already exists updates the existing one")
    func setBirthdayUpdatesExisting() {
        let ctx = TestSupport.makeContext()
        let person = TestSupport.seedPerson(in: ctx, name: "Alice")

        BirthdayService.setBirthday(date: TestFixtures.sampleBirthday, person: person, in: ctx)

        let newDate = TestFixtures.date(daysOffset: 60)
        BirthdayService.setBirthday(date: newDate, person: person, in: ctx)

        let dates = (person.importantDates ?? []).filter {
            $0.predefinedCategory == .birthday && $0.customCategory == nil
        }
        #expect(dates.count == 1)
        #expect(dates.first?.date == newDate)
        #expect(person.birthday == newDate)
    }

    @Test("Removing a birthday deletes the correct ImportantDate")
    func removeBirthdayDeletesDate() throws {
        let ctx = TestSupport.makeContext()
        let person = TestSupport.seedPerson(in: ctx, name: "Alice")

        BirthdayService.setBirthday(date: TestFixtures.sampleBirthday, person: person, in: ctx)
        let otherDate = TestSupport.seedImportantDate(
            in: ctx, title: "Anniversary",
            date: TestFixtures.referenceDate,
            predefinedCategory: .anniversary,
            person: person
        )

        BirthdayService.removeBirthday(person: person, in: ctx)
        try ctx.save()

        #expect(person.birthday == nil)
        let remaining = person.importantDates ?? []
        #expect(remaining.contains(where: { $0.predefinedCategory == .birthday }) == false)
        #expect(remaining.contains(otherDate))
    }

    @Test("Birthday ImportantDate is recurring")
    func birthdayIsRecurring() {
        let ctx = TestSupport.makeContext()
        let person = TestSupport.seedPerson(in: ctx, name: "Alice")

        BirthdayService.setBirthday(date: TestFixtures.sampleBirthday, person: person, in: ctx)

        let birthdayDate = (person.importantDates ?? []).first {
            $0.predefinedCategory == .birthday
        }
        #expect(birthdayDate?.isRecurring == true)
    }
}
