import Foundation
@testable import yours
import SwiftData

enum TestSupport {
    // MARK: - Full Schema

    static let schema = Schema([
        Person.self, Note.self, ImportantDate.self, DateCategory.self,
        GiftIdea.self, GiftCategory.self, AskAboutItem.self,
        LikeDislikeItem.self, LikeDislikeCategory.self,
        ClothingSizeItem.self, ClothingSizeCategory.self,
        AllergyItem.self, AllergyCategory.self,
        FoodOrderItem.self, FoodOrderCategory.self,
        TheirPeopleItem.self, TheirPeopleCategory.self,
        Quirk.self,
    ])

    // MARK: - In-Memory Context

    static func makeContext() -> ModelContext {
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true, cloudKitDatabase: .none)
        let container = try! ModelContainer(for: schema, configurations: [config])
        return ModelContext(container)
    }

    // MARK: - Person Seeding

    @discardableResult
    static func seedPerson(
        in context: ModelContext,
        name: String = "Test Person",
        relationshipStart: Date = TestFixtures.referenceDate,
        gender: Person.Gender = .other,
        birthday: Date? = nil
    ) -> Person {
        let person = Person(name: name, relationshipStart: relationshipStart, gender: gender)
        person.birthday = birthday
        context.insert(person)
        try! context.save()
        return person
    }

    // MARK: - Note Seeding

    @discardableResult
    static func seedNote(
        in context: ModelContext,
        body: String = "Test note",
        person: Person
    ) -> Note {
        let note = Note(body: body, person: person)
        context.insert(note)
        try! context.save()
        return note
    }

    // MARK: - Important Date Seeding

    @discardableResult
    static func seedImportantDate(
        in context: ModelContext,
        title: String = "Test Date",
        date: Date = TestFixtures.referenceDate,
        recurrenceFrequency: RecurrenceFrequency = .never,
        predefinedCategory: ImportantDatePredefinedCategory = .other,
        reminderEnabled: Bool = false,
        reminderDaysBefore: Int = 1,
        person: Person
    ) -> ImportantDate {
        let importantDate = ImportantDate(
            title: title,
            date: date,
            recurrenceFrequency: recurrenceFrequency,
            predefinedCategory: predefinedCategory,
            reminderEnabled: reminderEnabled,
            reminderDaysBefore: reminderDaysBefore,
            person: person
        )
        context.insert(importantDate)
        try! context.save()
        return importantDate
    }

    // MARK: - Gift Idea Seeding

    @discardableResult
    static func seedGiftIdea(
        in context: ModelContext,
        title: String = "Test Gift",
        price: Decimal? = nil,
        status: GiftStatus = .idea,
        predefinedCategory: GiftOccasion = .justBecause,
        person: Person
    ) -> GiftIdea {
        let gift = GiftIdea(
            title: title,
            price: price,
            status: status,
            predefinedCategory: predefinedCategory,
            person: person
        )
        context.insert(gift)
        try! context.save()
        return gift
    }

    // MARK: - Ask About Item Seeding

    @discardableResult
    static func seedAskAboutItem(
        in context: ModelContext,
        title: String = "Test Question",
        dueDate: Date? = nil,
        person: Person
    ) -> AskAboutItem {
        let item = AskAboutItem(title: title, person: person, dueDate: dueDate)
        context.insert(item)
        try! context.save()
        return item
    }

    // MARK: - Like/Dislike Seeding

    @discardableResult
    static func seedLikeDislike(
        in context: ModelContext,
        name: String = "Test Item",
        kind: LikeDislikeItem.Kind = .like,
        predefinedCategory: LikeDislikePredefinedCategory = .other,
        person: Person
    ) -> LikeDislikeItem {
        let item = LikeDislikeItem(
            name: name,
            kind: kind,
            predefinedCategory: predefinedCategory,
            person: person
        )
        context.insert(item)
        try! context.save()
        return item
    }

    // MARK: - Quirk Seeding

    @discardableResult
    static func seedQuirk(
        in context: ModelContext,
        text: String = "Test quirk",
        person: Person
    ) -> Quirk {
        let quirk = Quirk(text: text, person: person)
        context.insert(quirk)
        try! context.save()
        return quirk
    }

    // MARK: - Clothing Size Seeding

    @discardableResult
    static func seedClothingSize(
        in context: ModelContext,
        size: String = "M",
        predefinedCategory: ClothingSizePredefinedCategory = .other,
        person: Person
    ) -> ClothingSizeItem {
        let item = ClothingSizeItem(size: size, predefinedCategory: predefinedCategory, person: person)
        context.insert(item)
        try! context.save()
        return item
    }

    // MARK: - Allergy Seeding

    @discardableResult
    static func seedAllergy(
        in context: ModelContext,
        name: String = "Test Allergy",
        predefinedCategory: AllergyPredefinedCategory = .other,
        person: Person
    ) -> AllergyItem {
        let item = AllergyItem(name: name, predefinedCategory: predefinedCategory, person: person)
        context.insert(item)
        try! context.save()
        return item
    }

    // MARK: - Food Order Seeding

    @discardableResult
    static func seedFoodOrder(
        in context: ModelContext,
        place: String = "Test Cafe",
        order: String = "Latte",
        predefinedCategory: FoodOrderPredefinedCategory = .coffee,
        person: Person
    ) -> FoodOrderItem {
        let item = FoodOrderItem(
            place: place,
            order: order,
            predefinedCategory: predefinedCategory,
            person: person
        )
        context.insert(item)
        try! context.save()
        return item
    }

    // MARK: - Their People Seeding

    @discardableResult
    static func seedTheirPeople(
        in context: ModelContext,
        name: String = "Test Person",
        predefinedCategory: TheirPeoplePredefinedCategory = .friend,
        person: Person
    ) -> TheirPeopleItem {
        let item = TheirPeopleItem(
            name: name,
            predefinedCategory: predefinedCategory,
            person: person
        )
        context.insert(item)
        try! context.save()
        return item
    }

    // MARK: - Composite Helpers

    /// Seeds a person with a set of common related data for integration-style tests.
    @discardableResult
    static func seedPersonWithRelatedData(
        in context: ModelContext,
        name: String = "Test Person",
        noteCount: Int = 2,
        importantDateCount: Int = 2,
        giftIdeaCount: Int = 1
    ) -> Person {
        let person = seedPerson(in: context, name: name)

        for i in 0 ..< noteCount {
            seedNote(in: context, body: "Note \(i + 1)", person: person)
        }

        let calendar = Calendar.current
        for i in 0 ..< importantDateCount {
            let date = calendar.date(byAdding: .month, value: i + 1, to: TestFixtures.referenceDate)!
            seedImportantDate(
                in: context,
                title: "Date \(i + 1)",
                date: date,
                recurrenceFrequency: .yearly,
                person: person
            )
        }

        for i in 0 ..< giftIdeaCount {
            seedGiftIdea(in: context, title: "Gift \(i + 1)", person: person)
        }

        return person
    }
}
