import Foundation
import SwiftData

@Model
final class Person {
    var name: String = ""
    var relationshipStart: Date = Date.now
    var gender: Gender = Gender.other
    @Attribute(.externalStorage) var photoData: Data?
    var birthday: Date?
    @Relationship(deleteRule: .cascade, inverse: \Note.person)
    var notes: [Note]?
    @Relationship(deleteRule: .cascade, inverse: \ImportantDate.person)
    var importantDates: [ImportantDate]?
    @Relationship(deleteRule: .cascade, inverse: \GiftIdea.person)
    var giftIdeas: [GiftIdea]?
    @Relationship(deleteRule: .cascade, inverse: \AskAboutItem.person)
    var askAboutItems: [AskAboutItem]?
    @Relationship(deleteRule: .cascade, inverse: \LikeDislikeItem.person)
    var likeDislikeItems: [LikeDislikeItem]?
    @Relationship(deleteRule: .cascade, inverse: \ClothingSizeItem.person)
    var clothingSizeItems: [ClothingSizeItem]?
    @Relationship(deleteRule: .cascade, inverse: \AllergyItem.person)
    var allergyItems: [AllergyItem]?
    @Relationship(deleteRule: .cascade, inverse: \FoodOrderItem.person)
    var foodOrderItems: [FoodOrderItem]?
    @Relationship(deleteRule: .cascade, inverse: \Quirk.person)
    var quirks: [Quirk]?
    @Relationship(deleteRule: .cascade, inverse: \TheirPeopleItem.person)
    var theirPeopleItems: [TheirPeopleItem]?
    @Relationship(deleteRule: .cascade, inverse: \PetName.person)
    var petNames: [PetName]?
    @Relationship(deleteRule: .cascade, inverse: \Dream.person)
    var dreams: [Dream]?

    enum Gender: String, Codable {
        case female, male, other
    }

    init(name: String, relationshipStart: Date, gender: Gender) {
        self.name = name
        self.relationshipStart = relationshipStart
        self.gender = gender
    }

    var firstName: String {
        name.components(separatedBy: " ").first ?? name
    }

    func gendered(female: String, male: String, other: String) -> String {
        switch gender {
        case .female: female
        case .male: male
        case .other: other
        }
    }

    var age: Int? {
        guard let birthday else { return nil }
        return Calendar.current.dateComponents([.year], from: birthday, to: .now).year
    }

    var zodiacSign: ZodiacSign? {
        guard let birthday else { return nil }
        let components = Calendar.current.dateComponents([.month, .day], from: birthday)
        guard let month = components.month, let day = components.day else { return nil }
        return ZodiacSign.from(month: month, day: day)
    }

    var formattedBirthday: String? {
        birthday?.formatted(.dateTime.month(.wide).day().year())
    }

    var durationDescription: String {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: relationshipStart)
        let today = calendar.startOfDay(for: .now)
        let components = calendar.dateComponents(
            [.year, .month, .day],
            from: start,
            to: today
        )

        var parts: [String] = []
        if let years = components.year, years > 0 {
            parts.append(String(localized: "\(years) years", comment: "Duration: year count for relationship length"))
        }
        if let months = components.month, months > 0 {
            parts.append(String(localized: "\(months) months", comment: "Duration: month count for relationship length"))
        }
        if let days = components.day, days > 0 {
            parts.append(String(localized: "\(days) days", comment: "Duration: day count for relationship length"))
        }

        guard !parts.isEmpty else {
            return String(localized: "Together since today.", comment: "Duration: relationship started today")
        }

        let joined = ListFormatter.localizedString(byJoining: parts)
        return String(localized: "Together for \(joined).", comment: "Duration: relationship length summary")
    }
}

// MARK: - Preview Data

@MainActor
extension Person {
    // periphery:ignore
    static let preview: Person = {
        let person = Person(
            name: "Jane",
            relationshipStart: Calendar.current.date(
                from: DateComponents(year: 2024, month: 6, day: 12)
            ) ?? .now,
            gender: .female
        )
        person.birthday = Calendar.current.date(
            from: DateComponents(year: 1995, month: 3, day: 15)
        )
        return person
    }()

    var sortedNotes: [Note] {
        (notes ?? []).sorted { $0.createdAt > $1.createdAt }
    }

    var latestNote: Note? {
        (notes ?? []).max { $0.createdAt < $1.createdAt }
    }

    var upcomingDates: [ImportantDate] {
        (importantDates ?? [])
            .filter { !$0.isPast }
            .sorted { $0.daysUntilNext < $1.daysUntilNext }
    }

    var nearestDate: ImportantDate? {
        upcomingDates.first
    }

    var importantDateCount: Int {
        (importantDates ?? []).count
    }

    var activeGiftIdeas: [GiftIdea] {
        (giftIdeas ?? []).filter { $0.status != .archived }
    }

    var latestGiftIdea: GiftIdea? {
        activeGiftIdeas.max { $0.createdAt < $1.createdAt }
    }

    var giftIdeaCount: Int {
        activeGiftIdeas.count
    }

    var activeAskAboutItems: [AskAboutItem] {
        (askAboutItems ?? []).filter { !$0.isDone }
    }

    var askAboutItemCount: Int {
        activeAskAboutItems.count
    }

    var likes: [LikeDislikeItem] {
        (likeDislikeItems ?? []).filter { $0.kind == .like }
    }

    var dislikes: [LikeDislikeItem] {
        (likeDislikeItems ?? []).filter { $0.kind == .dislike }
    }

    var sortedQuirks: [Quirk] {
        (quirks ?? []).sorted { $0.createdAt > $1.createdAt }
    }

    var latestQuirk: Quirk? {
        (quirks ?? []).max { $0.createdAt < $1.createdAt }
    }

    var quirkCount: Int {
        (quirks ?? []).count
    }

    var sortedPetNames: [PetName] {
        (petNames ?? []).sorted { $0.createdAt > $1.createdAt }
    }

    var latestPetName: PetName? {
        (petNames ?? []).max { $0.createdAt < $1.createdAt }
    }

    var petNameCount: Int {
        (petNames ?? []).count
    }

    var daysUntilBirthday: Int? {
        guard let birthday else { return nil }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        let components = calendar.dateComponents([.month, .day], from: birthday)
        guard let next = calendar.nextDate(
            after: today.addingTimeInterval(-1),
            matching: components,
            matchingPolicy: .nextTime
        ) else { return nil }
        return calendar.dateComponents([.day], from: today, to: next).day
    }
}
