import Foundation
import SwiftData

/// Frozen snapshot of the schema as of v1.0.0.
/// Used as a baseline for future migrations via `YoursMigrationPlan`.
enum YoursSchemaV1: VersionedSchema {
    static let versionIdentifier = Schema.Version(1, 0, 0)

    static var models: [any PersistentModel.Type] {
        [
            YoursSchemaV1.Person.self, YoursSchemaV1.Note.self,
            YoursSchemaV1.ImportantDate.self, YoursSchemaV1.DateCategory.self,
            YoursSchemaV1.GiftIdea.self, YoursSchemaV1.GiftCategory.self,
            YoursSchemaV1.AskAboutItem.self,
            YoursSchemaV1.LikeDislikeItem.self, YoursSchemaV1.LikeDislikeCategory.self,
            YoursSchemaV1.ClothingSizeItem.self, YoursSchemaV1.ClothingSizeCategory.self,
            YoursSchemaV1.AllergyItem.self, YoursSchemaV1.AllergyCategory.self,
            YoursSchemaV1.FoodOrderItem.self, YoursSchemaV1.FoodOrderCategory.self,
            YoursSchemaV1.TheirPeopleItem.self, YoursSchemaV1.TheirPeopleCategory.self,
            YoursSchemaV1.Quirk.self,
        ]
    }

    enum Gender: String, Codable {
        case female, male, other
    }

    enum LikeDislikeKind: String, Codable {
        case like, dislike
    }

    // MARK: - Person

    @Model
    final class Person {
        var name: String = ""
        var relationshipStart: Date = Date.now
        var gender: Gender = Gender.other
        @Attribute(.externalStorage) var photoData: Data?
        var birthday: Date?
        @Relationship(deleteRule: .cascade, inverse: \YoursSchemaV1.Note.person)
        var notes: [Note]?
        @Relationship(deleteRule: .cascade, inverse: \YoursSchemaV1.ImportantDate.person)
        var importantDates: [ImportantDate]?
        @Relationship(deleteRule: .cascade, inverse: \YoursSchemaV1.GiftIdea.person)
        var giftIdeas: [GiftIdea]?
        @Relationship(deleteRule: .cascade, inverse: \YoursSchemaV1.AskAboutItem.person)
        var askAboutItems: [AskAboutItem]?
        @Relationship(deleteRule: .cascade, inverse: \YoursSchemaV1.LikeDislikeItem.person)
        var likeDislikeItems: [LikeDislikeItem]?
        @Relationship(deleteRule: .cascade, inverse: \YoursSchemaV1.ClothingSizeItem.person)
        var clothingSizeItems: [ClothingSizeItem]?
        @Relationship(deleteRule: .cascade, inverse: \YoursSchemaV1.AllergyItem.person)
        var allergyItems: [AllergyItem]?
        @Relationship(deleteRule: .cascade, inverse: \YoursSchemaV1.FoodOrderItem.person)
        var foodOrderItems: [FoodOrderItem]?
        @Relationship(deleteRule: .cascade, inverse: \YoursSchemaV1.Quirk.person)
        var quirks: [Quirk]?
        @Relationship(deleteRule: .cascade, inverse: \YoursSchemaV1.TheirPeopleItem.person)
        var theirPeopleItems: [TheirPeopleItem]?

        init() {}
    }

    // MARK: - Note

    @Model
    final class Note {
        var body: String = ""
        var createdAt: Date = Date.now
        var updatedAt: Date = Date.now
        var person: Person?

        init() {}
    }

    // MARK: - ImportantDate

    @Model
    final class ImportantDate {
        var title: String = ""
        var date: Date = Date.now
        var note: String?
        var recurrenceFrequency: RecurrenceFrequency = RecurrenceFrequency.never
        var predefinedCategory: ImportantDatePredefinedCategory = ImportantDatePredefinedCategory.other
        var customCategory: DateCategory?
        var reminderEnabled: Bool = false
        var reminderDaysBefore: Int = 1
        var createdAt: Date = Date.now
        var updatedAt: Date = Date.now
        @Relationship(deleteRule: .nullify, inverse: \YoursSchemaV1.GiftIdea.linkedDate)
        var linkedGiftIdeas: [GiftIdea]?
        var person: Person?

        init() {}
    }

    // MARK: - DateCategory

    @Model
    final class DateCategory {
        var name: String = ""
        var sfSymbol: String = ""
        var colorName: String = ""
        var createdAt: Date = Date.now
        var updatedAt: Date = Date.now
        @Relationship(deleteRule: .nullify, inverse: \YoursSchemaV1.ImportantDate.customCategory)
        var dates: [ImportantDate]?

        init() {}
    }

    // MARK: - GiftIdea

    @Model
    final class GiftIdea {
        var title: String = ""
        var note: String?
        var price: Decimal?
        var urlString: String?
        var status: GiftStatus = GiftStatus.idea
        var createdAt: Date = Date.now
        var updatedAt: Date = Date.now
        var predefinedCategory: GiftOccasion = GiftOccasion.justBecause
        var customCategory: GiftCategory?
        var linkedDate: ImportantDate?
        var person: Person?

        init() {}
    }

    // MARK: - GiftCategory

    @Model
    final class GiftCategory {
        var name: String = ""
        var sfSymbol: String = ""
        var colorName: String = ""
        var createdAt: Date = Date.now
        var updatedAt: Date = Date.now
        @Relationship(deleteRule: .nullify, inverse: \YoursSchemaV1.GiftIdea.customCategory)
        var giftIdeas: [GiftIdea]?

        init() {}
    }

    // MARK: - AskAboutItem

    @Model
    final class AskAboutItem {
        var title: String = ""
        var isDone: Bool = false
        var dueDate: Date?
        var createdAt: Date = Date.now
        var updatedAt: Date = Date.now
        var person: Person?

        init() {}
    }

    // MARK: - LikeDislikeItem

    @Model
    final class LikeDislikeItem {
        var name: String = ""
        var note: String?
        var kind: LikeDislikeKind = LikeDislikeKind.like
        var predefinedCategory: LikeDislikePredefinedCategory = LikeDislikePredefinedCategory.other
        var customCategory: LikeDislikeCategory?
        var createdAt: Date = Date.now
        var updatedAt: Date = Date.now
        var person: Person?

        init() {}
    }

    // MARK: - LikeDislikeCategory

    @Model
    final class LikeDislikeCategory {
        var name: String = ""
        var sfSymbol: String = ""
        var colorName: String = ""
        var createdAt: Date = Date.now
        var updatedAt: Date = Date.now
        @Relationship(deleteRule: .nullify, inverse: \YoursSchemaV1.LikeDislikeItem.customCategory)
        var items: [LikeDislikeItem]?

        init() {}
    }

    // MARK: - ClothingSizeItem

    @Model
    final class ClothingSizeItem {
        var size: String = ""
        var note: String?
        var predefinedCategory: ClothingSizePredefinedCategory = ClothingSizePredefinedCategory.other
        var customCategory: ClothingSizeCategory?
        var createdAt: Date = Date.now
        var updatedAt: Date = Date.now
        var person: Person?

        init() {}
    }

    // MARK: - ClothingSizeCategory

    @Model
    final class ClothingSizeCategory {
        var name: String = ""
        var sfSymbol: String = ""
        var colorName: String = ""
        var createdAt: Date = Date.now
        var updatedAt: Date = Date.now
        @Relationship(deleteRule: .nullify, inverse: \YoursSchemaV1.ClothingSizeItem.customCategory)
        var items: [ClothingSizeItem]?

        init() {}
    }

    // MARK: - AllergyItem

    @Model
    final class AllergyItem {
        var name: String = ""
        var note: String?
        var predefinedCategory: AllergyPredefinedCategory = AllergyPredefinedCategory.other
        var customCategory: AllergyCategory?
        var createdAt: Date = Date.now
        var updatedAt: Date = Date.now
        var person: Person?

        init() {}
    }

    // MARK: - AllergyCategory

    @Model
    final class AllergyCategory {
        var name: String = ""
        var sfSymbol: String = ""
        var colorName: String = ""
        var createdAt: Date = Date.now
        var updatedAt: Date = Date.now
        @Relationship(deleteRule: .nullify, inverse: \YoursSchemaV1.AllergyItem.customCategory)
        var items: [AllergyItem]?

        init() {}
    }

    // MARK: - FoodOrderItem

    @Model
    final class FoodOrderItem {
        var place: String = ""
        var order: String = ""
        var note: String?
        var predefinedCategory: FoodOrderPredefinedCategory = FoodOrderPredefinedCategory.other
        var customCategory: FoodOrderCategory?
        var sortOrder: Int = 0
        var createdAt: Date = Date.now
        var updatedAt: Date = Date.now
        var person: Person?

        init() {}
    }

    // MARK: - FoodOrderCategory

    @Model
    final class FoodOrderCategory {
        var name: String = ""
        var sfSymbol: String = ""
        var colorName: String = ""
        var createdAt: Date = Date.now
        var updatedAt: Date = Date.now
        @Relationship(deleteRule: .nullify, inverse: \YoursSchemaV1.FoodOrderItem.customCategory)
        var items: [FoodOrderItem]?

        init() {}
    }

    // MARK: - Quirk

    @Model
    final class Quirk {
        var text: String = ""
        var createdAt: Date = Date.now
        var updatedAt: Date = Date.now
        var person: Person?

        init() {}
    }

    // MARK: - TheirPeopleItem

    @Model
    final class TheirPeopleItem {
        var name: String = ""
        var note: String?
        var predefinedCategory: TheirPeoplePredefinedCategory = TheirPeoplePredefinedCategory.other
        var customCategory: TheirPeopleCategory?
        var createdAt: Date = Date.now
        var updatedAt: Date = Date.now
        var person: Person?

        init() {}
    }

    // MARK: - TheirPeopleCategory

    @Model
    final class TheirPeopleCategory {
        var name: String = ""
        var sfSymbol: String = ""
        var colorName: String = ""
        var createdAt: Date = Date.now
        var updatedAt: Date = Date.now
        @Relationship(deleteRule: .nullify, inverse: \YoursSchemaV1.TheirPeopleItem.customCategory)
        var items: [TheirPeopleItem]?

        init() {}
    }
}
