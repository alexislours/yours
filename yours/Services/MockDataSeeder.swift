#if DEBUG
    import Foundation
    import SwiftData
    import UIKit

    @MainActor
    enum MockDataSeeder {
        static func seed(modelContext: ModelContext) {
            let photoData = loadProfilePhoto()

            let person = Person(
                name: "Emma",
                relationshipStart: Calendar.current.date(
                    from: DateComponents(year: 2024, month: 8, day: 20)
                ) ?? .now,
                gender: .female
            )
            person.birthday = Calendar.current.date(
                from: DateComponents(year: 1995, month: 3, day: 29)
            )
            person.photoData = photoData
            modelContext.insert(person)

            seedImportantDates(for: person, in: modelContext)
            seedGiftIdeas(for: person, in: modelContext)
            seedLikesAndDislikes(for: person, in: modelContext)
            seedClothingSizes(for: person, in: modelContext)
            seedAllergies(for: person, in: modelContext)
            seedFoodOrders(for: person, in: modelContext)
            seedTheirPeople(for: person, in: modelContext)
            seedNotes(for: person, in: modelContext)
            seedAskAboutItems(for: person, in: modelContext)
            seedQuirks(for: person, in: modelContext)
            seedPetNames(for: person, in: modelContext)
            seedDreams(for: person, in: modelContext)
        }

        // MARK: - Profile Photo

        private static func loadProfilePhoto() -> Data? {
            guard let url = Bundle.main.url(forResource: "profile", withExtension: "jpg"),
                  let image = UIImage(contentsOfFile: url.path)
            else { return nil }
            let resized = image.resizedTo512()
            return resized.jpegData(compressionQuality: 0.8)
        }

        // MARK: - Important Dates

        private static func seedImportantDates(for person: Person, in context: ModelContext) {
            let calendar = Calendar.current

            // Birthday: ~12 days from now (recurring)
            let birthdayDate = calendar.date(
                from: DateComponents(year: 1995, month: 3, day: 29)
            ) ?? .now
            let birthday = ImportantDate(
                title: "Her Birthday",
                date: birthdayDate,
                recurrenceFrequency: .yearly,
                predefinedCategory: .birthday,
                reminderEnabled: true,
                reminderDaysBefore: 7,
                person: person
            )
            context.insert(birthday)

            // Anniversary: ~34 days from now (recurring)
            let anniversaryDate = calendar.date(
                from: DateComponents(year: 2024, month: 8, day: 20)
            ) ?? .now
            let anniversary = ImportantDate(
                title: "Our Anniversary",
                date: anniversaryDate,
                recurrenceFrequency: .yearly,
                predefinedCategory: .anniversary,
                reminderEnabled: true,
                reminderDaysBefore: 14,
                person: person
            )
            context.insert(anniversary)

            // Custom milestone: future date
            let tripCategory = DateCategory(name: "Trips", sfSymbol: "suitcase.fill", colorName: "eucalyptus")
            context.insert(tripCategory)

            let tripDate = calendar.date(byAdding: .day, value: 58, to: .now) ?? .now
            let trip = ImportantDate(
                title: "Our first trip",
                date: tripDate,
                note: "Flight at 7am, pack light!",
                predefinedCategory: .other,
                customCategory: tripCategory,
                reminderEnabled: true,
                reminderDaysBefore: 30,
                person: person
            )
            context.insert(trip)

            // Holiday
            let holidayDate = calendar.date(byAdding: .day, value: 95, to: .now) ?? .now
            let holiday = ImportantDate(
                title: "Summer cabin weekend",
                date: holidayDate,
                recurrenceFrequency: .never,
                predefinedCategory: .holiday,
                person: person
            )
            context.insert(holiday)
        }

        // MARK: - Gift Ideas

        private static func seedGiftIdeas(for person: Person, in context: ModelContext) {
            context.insert(GiftIdea(
                title: "Silk scarf from that boutique", price: 85,
                urlString: "https://shop.example.com/scarf",
                status: .idea, predefinedCategory: .justBecause, person: person
            ))
            context.insert(GiftIdea(
                title: "Instant film camera", price: 120,
                status: .idea, predefinedCategory: .birthday, person: person
            ))
            context.insert(GiftIdea(
                title: "E-reader", price: 140,
                status: .purchased, predefinedCategory: .birthday, person: person
            ))
            context.insert(GiftIdea(
                title: "Custom star map print", price: 55,
                status: .given, predefinedCategory: .anniversary, person: person
            ))
            context.insert(GiftIdea(
                title: "Weekend cabin getaway", price: 250,
                status: .idea, predefinedCategory: .anniversary, person: person
            ))
        }

        // MARK: - Likes & Dislikes

        private static func seedLikesAndDislikes(for person: Person, in context: ModelContext) {
            let likes: [(String, LikeDislikePredefinedCategory)] = [
                ("Matcha lattes", .foodDrinks),
                ("Indie folk playlists", .music),
                ("Animated films", .moviesTv),
                ("Hiking at sunrise", .activitiesHobbies),
                ("Sage green", .colors),
                ("Tokyo", .travel),
                ("Vintage denim", .fashionStyle),
                ("Golden retrievers", .animals),
            ]

            for (name, category) in likes {
                let item = LikeDislikeItem(
                    name: name,
                    kind: .like,
                    predefinedCategory: category,
                    person: person
                )
                context.insert(item)
            }

            let dislikes: [(String, LikeDislikePredefinedCategory)] = [
                ("Cilantro", .foodDrinks),
                ("Horror movies", .moviesTv),
                ("Crowded malls", .other),
            ]

            for (name, category) in dislikes {
                let item = LikeDislikeItem(
                    name: name,
                    kind: .dislike,
                    predefinedCategory: category,
                    person: person
                )
                context.insert(item)
            }
        }

        // MARK: - Clothing Sizes

        private static func seedClothingSizes(for person: Person, in context: ModelContext) {
            let sizes: [(String, ClothingSizePredefinedCategory)] = [
                ("S", .tops),
                ("26", .bottoms),
                ("EU 38", .shoes),
                ("S", .dresses),
                ("M", .outerwear),
                ("US 6", .rings),
            ]

            for (size, category) in sizes {
                let item = ClothingSizeItem(
                    size: size,
                    predefinedCategory: category,
                    person: person
                )
                context.insert(item)
            }
        }

        // MARK: - Allergies

        private static func seedAllergies(for person: Person, in context: ModelContext) {
            let allergies: [(String, AllergyPredefinedCategory)] = [
                ("Shellfish", .food),
                ("Penicillin", .medication),
                ("Lactose intolerant", .dietary),
            ]

            for (name, category) in allergies {
                let item = AllergyItem(
                    name: name,
                    predefinedCategory: category,
                    person: person
                )
                context.insert(item)
            }
        }

        // MARK: - Food Orders

        private static func seedFoodOrders(for person: Person, in context: ModelContext) {
            seedOrder("The Corner Cafe", order: "Oat milk latte, no sugar", category: .coffee, person: person, in: context)
            seedOrder("Green Bowl", order: "Harvest bowl, extra avocado", category: .lunch, person: person, in: context)
            seedOrder("Kawa Sushi", order: "Omakase, no uni", category: .dinner, person: person, in: context)
            seedOrder("Sugar & Flour", order: "Dark chocolate cookie", category: .dessert, person: person, in: context)
        }

        private static func seedOrder(
            _ place: String,
            order: String,
            category: FoodOrderPredefinedCategory,
            person: Person,
            in context: ModelContext
        ) {
            let item = FoodOrderItem(place: place, order: order, predefinedCategory: category, person: person)
            context.insert(item)
        }

        // MARK: - Their People

        private static func seedTheirPeople(for person: Person, in context: ModelContext) {
            seedPerson("Catherine", category: .mom, note: "Loves gardening, calls every Sunday", person: person, in: context)
            seedPerson("Marc", category: .dad, person: person, in: context)
            seedPerson("Lucas", category: .sibling, note: "Her younger brother, lives in Portland", person: person, in: context)
            seedPerson("Sophia", category: .friend, note: "College roommate, always up for brunch", person: person, in: context)
        }

        private static func seedPerson(
            _ name: String,
            category: TheirPeoplePredefinedCategory,
            note: String? = nil,
            person: Person,
            in context: ModelContext
        ) {
            let item = TheirPeopleItem(name: name, note: note, predefinedCategory: category, person: person)
            context.insert(item)
        }

        // MARK: - Notes

        private static func seedNotes(for person: Person, in context: ModelContext) {
            let notes = [
                "She mentioned wanting to try pottery classes. Look into studios near the apartment.",
                "Her favorite flower is peonies, especially the blush pink ones. Remember for next bouquet.",
            ]

            for body in notes {
                let note = Note(body: body, person: person)
                context.insert(note)
            }
        }

        // MARK: - Ask About Items

        private static func seedAskAboutItems(for person: Person, in context: ModelContext) {
            let items = [
                "How did the job interview go?",
                "Did she finish that book club pick?",
                "Weekend plans with Sophia?",
            ]

            for title in items {
                let item = AskAboutItem(title: title, person: person)
                context.insert(item)
            }
        }

        // MARK: - Quirks

        private static func seedQuirks(for person: Person, in context: ModelContext) {
            let quirks = [
                "Always orders dessert first when she's stressed.",
                "Sleeps with exactly three pillows, no exceptions.",
                "Has a thing about organizing books by color on shelves.",
            ]

            for text in quirks {
                let quirk = Quirk(text: text, person: person)
                context.insert(quirk)
            }
        }

        // MARK: - Pet Names

        private static func seedPetNames(for person: Person, in context: ModelContext) {
            let names = [
                "Sunshine",
                "Love bug",
                "Em",
            ]

            for name in names {
                let petName = PetName(text: name, person: person)
                context.insert(petName)
            }
        }

        // MARK: - Dreams

        private static func seedDreams(for person: Person, in context: ModelContext) {
            let dreams = [
                "Publish a novel",
                "Visit every continent",
                "Open a little bakery someday",
            ]

            for text in dreams {
                let dream = Dream(text: text, person: person)
                context.insert(dream)
            }
        }
    }
#endif
