import Foundation
import SwiftData
import Testing
@testable import yours

@Suite("PetName Model", .tags(.models, .petNames))
@MainActor
struct PetNameTests {
    @Test("Formatted date returns month and year")
    func formattedDate() {
        let ctx = TestSupport.makeContext()
        let person = TestSupport.seedPerson(in: ctx)
        let petName = TestSupport.seedPetName(in: ctx, text: "Babe", person: person)

        let formatted = petName.formattedDate
        #expect(!formatted.isEmpty)
    }

    @Test("Timestamps are set on creation")
    func timestamps() {
        let ctx = TestSupport.makeContext()
        let person = TestSupport.seedPerson(in: ctx)
        let before = Date.now
        let petName = TestSupport.seedPetName(in: ctx, text: "Love", person: person)

        #expect(petName.createdAt >= before)
        #expect(petName.updatedAt >= before)
    }

    @Test("Text is preserved after save")
    func textPersistence() throws {
        let ctx = TestSupport.makeContext()
        let person = TestSupport.seedPerson(in: ctx)
        TestSupport.seedPetName(in: ctx, text: "Sweetheart", person: person)

        let fetched = try ctx.fetch(FetchDescriptor<PetName>())
        #expect(fetched.count == 1)
        #expect(fetched.first?.text == "Sweetheart")
    }

    @Test("Multiple pet names can be added to a person")
    func multiplePetNames() {
        let ctx = TestSupport.makeContext()
        let person = TestSupport.seedPerson(in: ctx)
        TestSupport.seedPetName(in: ctx, text: "Babe", person: person)
        TestSupport.seedPetName(in: ctx, text: "Love", person: person)
        TestSupport.seedPetName(in: ctx, text: "Sunshine", person: person)

        #expect(person.petNameCount == 3)
    }

    @Test("sortedPetNames returns newest first")
    func sortedPetNames() throws {
        let ctx = TestSupport.makeContext()
        let person = TestSupport.seedPerson(in: ctx)

        let old = TestSupport.seedPetName(in: ctx, text: "Old", person: person)
        old.createdAt = TestFixtures.date(daysOffset: -5)
        let recent = TestSupport.seedPetName(in: ctx, text: "Recent", person: person)
        recent.createdAt = TestFixtures.referenceDate
        try ctx.save()

        let sorted = person.sortedPetNames
        #expect(sorted.count == 2)
        #expect(sorted[0].text == "Recent")
        #expect(sorted[1].text == "Old")
    }

    @Test("latestPetName returns most recent")
    func latestPetName() throws {
        let ctx = TestSupport.makeContext()
        let person = TestSupport.seedPerson(in: ctx)

        let old = TestSupport.seedPetName(in: ctx, text: "Old", person: person)
        old.createdAt = TestFixtures.date(daysOffset: -5)
        let recent = TestSupport.seedPetName(in: ctx, text: "Recent", person: person)
        recent.createdAt = TestFixtures.referenceDate
        try ctx.save()

        #expect(person.latestPetName?.text == "Recent")
    }

    @Test("latestPetName returns nil when empty")
    func latestPetNameEmpty() {
        let ctx = TestSupport.makeContext()
        let person = TestSupport.seedPerson(in: ctx)
        #expect(person.latestPetName == nil)
    }

    @Test("petNameCount matches total")
    func petNameCount() {
        let ctx = TestSupport.makeContext()
        let person = TestSupport.seedPerson(in: ctx)

        TestSupport.seedPetName(in: ctx, text: "A", person: person)
        TestSupport.seedPetName(in: ctx, text: "B", person: person)

        #expect(person.petNameCount == 2)
    }
}
