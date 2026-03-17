import Foundation
import SwiftData
import Testing
@testable import yours

// MARK: - Cascade Deletes

@Suite("Data Integrity – Cascade Deletes", .tags(.models, .dataIntegrity))
@MainActor
struct CascadeDeleteTests {
    @Test("Deleting a Person deletes all related items")
    func deletingPersonCascadesAllRelationships() throws {
        let ctx = TestSupport.makeContext()
        let person = TestSupport.seedPerson(in: ctx)

        TestSupport.seedNote(in: ctx, person: person)
        TestSupport.seedImportantDate(in: ctx, person: person)
        TestSupport.seedGiftIdea(in: ctx, person: person)
        TestSupport.seedAskAboutItem(in: ctx, person: person)
        TestSupport.seedLikeDislike(in: ctx, person: person)
        TestSupport.seedClothingSize(in: ctx, person: person)
        TestSupport.seedAllergy(in: ctx, person: person)
        TestSupport.seedFoodOrder(in: ctx, person: person)
        TestSupport.seedQuirk(in: ctx, person: person)
        TestSupport.seedTheirPeople(in: ctx, person: person)

        ctx.delete(person)
        try ctx.save()

        #expect(try ctx.fetch(FetchDescriptor<Note>()).isEmpty)
        #expect(try ctx.fetch(FetchDescriptor<ImportantDate>()).isEmpty)
        #expect(try ctx.fetch(FetchDescriptor<GiftIdea>()).isEmpty)
        #expect(try ctx.fetch(FetchDescriptor<AskAboutItem>()).isEmpty)
        #expect(try ctx.fetch(FetchDescriptor<LikeDislikeItem>()).isEmpty)
        #expect(try ctx.fetch(FetchDescriptor<ClothingSizeItem>()).isEmpty)
        #expect(try ctx.fetch(FetchDescriptor<AllergyItem>()).isEmpty)
        #expect(try ctx.fetch(FetchDescriptor<FoodOrderItem>()).isEmpty)
        #expect(try ctx.fetch(FetchDescriptor<Quirk>()).isEmpty)
        #expect(try ctx.fetch(FetchDescriptor<TheirPeopleItem>()).isEmpty)
    }

    @Test("Deleting a custom DateCategory does not delete items using it")
    func deletingDateCategoryNullifiesItems() throws {
        let ctx = TestSupport.makeContext()
        let person = TestSupport.seedPerson(in: ctx)

        let category = DateCategory(name: "Custom", sfSymbol: "star.fill", colorName: "slate")
        ctx.insert(category)
        try ctx.save()

        let importantDate = ImportantDate(
            title: "Event",
            date: TestFixtures.referenceDate,
            customCategory: category,
            person: person
        )
        ctx.insert(importantDate)
        try ctx.save()

        ctx.delete(category)
        try ctx.save()

        let dates = try ctx.fetch(FetchDescriptor<ImportantDate>())
        #expect(dates.count == 1)
        #expect(dates.first?.customCategory == nil)
    }

    @Test("Deleting a custom GiftCategory does not delete items using it")
    func deletingGiftCategoryNullifiesItems() throws {
        let ctx = TestSupport.makeContext()
        let person = TestSupport.seedPerson(in: ctx)

        let category = GiftCategory(name: "Custom", sfSymbol: "star.fill", colorName: "slate")
        ctx.insert(category)
        try ctx.save()

        let gift = GiftIdea(title: "Gift", person: person)
        gift.customCategory = category
        ctx.insert(gift)
        try ctx.save()

        ctx.delete(category)
        try ctx.save()

        let gifts = try ctx.fetch(FetchDescriptor<GiftIdea>())
        #expect(gifts.count == 1)
        #expect(gifts.first?.customCategory == nil)
    }
}

// MARK: - SwiftData Persistence

@Suite("Data Integrity – SwiftData Persistence", .tags(.models, .dataIntegrity))
@MainActor
struct SwiftDataPersistenceTests {
    @Test("Person saves and fetches correctly")
    func personPersistence() throws {
        let ctx = TestSupport.makeContext()
        let person = TestSupport.seedPerson(
            in: ctx,
            name: "Alice",
            relationshipStart: TestFixtures.sampleRelationshipStart,
            gender: .female,
            birthday: TestFixtures.sampleBirthday
        )

        let fetched = try ctx.fetch(FetchDescriptor<Person>())
        #expect(fetched.count == 1)
        #expect(fetched.first?.name == "Alice")
        #expect(fetched.first?.gender == .female)
        #expect(fetched.first?.birthday == person.birthday)
        #expect(fetched.first?.relationshipStart == person.relationshipStart)
    }

    @Test("Note saves and fetches correctly")
    func notePersistence() throws {
        let ctx = TestSupport.makeContext()
        let person = TestSupport.seedPerson(in: ctx)
        TestSupport.seedNote(in: ctx, body: "Hello world", person: person)

        let fetched = try ctx.fetch(FetchDescriptor<Note>())
        #expect(fetched.count == 1)
        #expect(fetched.first?.body == "Hello world")
    }

    @Test("ImportantDate saves and fetches correctly")
    func importantDatePersistence() throws {
        let ctx = TestSupport.makeContext()
        let person = TestSupport.seedPerson(in: ctx)
        TestSupport.seedImportantDate(
            in: ctx,
            title: "Anniversary",
            date: TestFixtures.referenceDate,
            recurrenceFrequency: .yearly,
            predefinedCategory: .anniversary,
            reminderEnabled: true,
            reminderDaysBefore: 7,
            person: person
        )

        let fetched = try ctx.fetch(FetchDescriptor<ImportantDate>())
        #expect(fetched.count == 1)
        #expect(fetched.first?.title == "Anniversary")
        #expect(fetched.first?.isRecurring == true)
        #expect(fetched.first?.predefinedCategory == .anniversary)
        #expect(fetched.first?.reminderEnabled == true)
        #expect(fetched.first?.reminderDaysBefore == 7)
    }

    @Test("GiftIdea saves and fetches correctly")
    func giftIdeaPersistence() throws {
        let ctx = TestSupport.makeContext()
        let person = TestSupport.seedPerson(in: ctx)
        TestSupport.seedGiftIdea(
            in: ctx,
            title: "Watch",
            price: 199.99,
            status: .purchased,
            predefinedCategory: .birthday,
            person: person
        )

        let fetched = try ctx.fetch(FetchDescriptor<GiftIdea>())
        #expect(fetched.count == 1)
        #expect(fetched.first?.title == "Watch")
        #expect(fetched.first?.price == 199.99)
        #expect(fetched.first?.status == .purchased)
        #expect(fetched.first?.predefinedCategory == .birthday)
    }

    @Test("AskAboutItem saves and fetches correctly")
    func askAboutItemPersistence() throws {
        let ctx = TestSupport.makeContext()
        let person = TestSupport.seedPerson(in: ctx)
        TestSupport.seedAskAboutItem(
            in: ctx,
            title: "Favorite movie?",
            dueDate: TestFixtures.referenceDate,
            person: person
        )

        let fetched = try ctx.fetch(FetchDescriptor<AskAboutItem>())
        #expect(fetched.count == 1)
        #expect(fetched.first?.title == "Favorite movie?")
        #expect(fetched.first?.dueDate == TestFixtures.referenceDate)
    }

    @Test("LikeDislikeItem saves and fetches correctly")
    func likeDislikeItemPersistence() throws {
        let ctx = TestSupport.makeContext()
        let person = TestSupport.seedPerson(in: ctx)
        TestSupport.seedLikeDislike(
            in: ctx,
            name: "Sushi",
            kind: .like,
            predefinedCategory: .foodDrinks,
            person: person
        )

        let fetched = try ctx.fetch(FetchDescriptor<LikeDislikeItem>())
        #expect(fetched.count == 1)
        #expect(fetched.first?.name == "Sushi")
        #expect(fetched.first?.kind == .like)
        #expect(fetched.first?.predefinedCategory == .foodDrinks)
    }

    @Test("ClothingSizeItem saves and fetches correctly")
    func clothingSizeItemPersistence() throws {
        let ctx = TestSupport.makeContext()
        let person = TestSupport.seedPerson(in: ctx)
        TestSupport.seedClothingSize(
            in: ctx,
            size: "42",
            predefinedCategory: .shoes,
            person: person
        )

        let fetched = try ctx.fetch(FetchDescriptor<ClothingSizeItem>())
        #expect(fetched.count == 1)
        #expect(fetched.first?.size == "42")
        #expect(fetched.first?.predefinedCategory == .shoes)
    }

    @Test("AllergyItem saves and fetches correctly")
    func allergyItemPersistence() throws {
        let ctx = TestSupport.makeContext()
        let person = TestSupport.seedPerson(in: ctx)
        TestSupport.seedAllergy(
            in: ctx,
            name: "Peanuts",
            predefinedCategory: .food,
            person: person
        )

        let fetched = try ctx.fetch(FetchDescriptor<AllergyItem>())
        #expect(fetched.count == 1)
        #expect(fetched.first?.name == "Peanuts")
        #expect(fetched.first?.predefinedCategory == .food)
    }

    @Test("FoodOrderItem saves and fetches correctly")
    func foodOrderItemPersistence() throws {
        let ctx = TestSupport.makeContext()
        let person = TestSupport.seedPerson(in: ctx)
        TestSupport.seedFoodOrder(
            in: ctx,
            place: "Blue Bottle",
            order: "Oat latte",
            predefinedCategory: .coffee,
            person: person
        )

        let fetched = try ctx.fetch(FetchDescriptor<FoodOrderItem>())
        #expect(fetched.count == 1)
        #expect(fetched.first?.place == "Blue Bottle")
        #expect(fetched.first?.order == "Oat latte")
        #expect(fetched.first?.predefinedCategory == .coffee)
    }

    @Test("Quirk saves and fetches correctly")
    func quirkPersistence() throws {
        let ctx = TestSupport.makeContext()
        let person = TestSupport.seedPerson(in: ctx)
        TestSupport.seedQuirk(in: ctx, text: "Always cold", person: person)

        let fetched = try ctx.fetch(FetchDescriptor<Quirk>())
        #expect(fetched.count == 1)
        #expect(fetched.first?.text == "Always cold")
    }

    @Test("TheirPeopleItem saves and fetches correctly")
    func theirPeopleItemPersistence() throws {
        let ctx = TestSupport.makeContext()
        let person = TestSupport.seedPerson(in: ctx)
        TestSupport.seedTheirPeople(
            in: ctx,
            name: "Sarah",
            predefinedCategory: .mom,
            person: person
        )

        let fetched = try ctx.fetch(FetchDescriptor<TheirPeopleItem>())
        #expect(fetched.count == 1)
        #expect(fetched.first?.name == "Sarah")
        #expect(fetched.first?.predefinedCategory == .mom)
    }

    // MARK: - Relationships

    @Test("Note relationship is established on both sides")
    func noteRelationship() throws {
        let ctx = TestSupport.makeContext()
        let person = TestSupport.seedPerson(in: ctx)
        let note = TestSupport.seedNote(in: ctx, person: person)

        #expect(note.person === person)
        #expect(person.notes?.contains(where: { $0 === note }) == true)
    }

    @Test("ImportantDate relationship is established on both sides")
    func importantDateRelationship() throws {
        let ctx = TestSupport.makeContext()
        let person = TestSupport.seedPerson(in: ctx)
        let date = TestSupport.seedImportantDate(in: ctx, person: person)

        #expect(date.person === person)
        #expect(person.importantDates?.contains(where: { $0 === date }) == true)
    }

    @Test("GiftIdea relationship is established on both sides")
    func giftIdeaRelationship() throws {
        let ctx = TestSupport.makeContext()
        let person = TestSupport.seedPerson(in: ctx)
        let gift = TestSupport.seedGiftIdea(in: ctx, person: person)

        #expect(gift.person === person)
        #expect(person.giftIdeas?.contains(where: { $0 === gift }) == true)
    }

    @Test("All relationship arrays are populated after save")
    func allRelationshipsPopulated() throws {
        let ctx = TestSupport.makeContext()
        let person = TestSupport.seedPerson(in: ctx)

        TestSupport.seedNote(in: ctx, person: person)
        TestSupport.seedImportantDate(in: ctx, person: person)
        TestSupport.seedGiftIdea(in: ctx, person: person)
        TestSupport.seedAskAboutItem(in: ctx, person: person)
        TestSupport.seedLikeDislike(in: ctx, person: person)
        TestSupport.seedClothingSize(in: ctx, person: person)
        TestSupport.seedAllergy(in: ctx, person: person)
        TestSupport.seedFoodOrder(in: ctx, person: person)
        TestSupport.seedQuirk(in: ctx, person: person)
        TestSupport.seedTheirPeople(in: ctx, person: person)

        #expect(person.notes?.count == 1)
        #expect(person.importantDates?.count == 1)
        #expect(person.giftIdeas?.count == 1)
        #expect(person.askAboutItems?.count == 1)
        #expect(person.likeDislikeItems?.count == 1)
        #expect(person.clothingSizeItems?.count == 1)
        #expect(person.allergyItems?.count == 1)
        #expect(person.foodOrderItems?.count == 1)
        #expect(person.quirks?.count == 1)
        #expect(person.theirPeopleItems?.count == 1)
    }

    // MARK: - External Storage

    @Test("Photo data persists and retrieves with external storage")
    func photoExternalStorage() throws {
        let ctx = TestSupport.makeContext()
        let person = TestSupport.seedPerson(in: ctx)

        let photoBytes = Data(repeating: 0xFF, count: 1024)
        person.photoData = photoBytes
        try ctx.save()

        let fetched = try ctx.fetch(FetchDescriptor<Person>())
        #expect(fetched.first?.photoData == photoBytes)
    }
}
