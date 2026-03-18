import SwiftData
import UIKit
import WidgetKit

enum OnboardingService {
    struct Input {
        let name: String
        let photo: UIImage?
        let gender: Person.Gender
        let startDate: Date
        let firstLike: String
    }

    @MainActor
    static func complete(
        _ input: Input,
        modelContext: ModelContext,
        widgetReloader: WidgetReloading = WidgetCenter.shared,
        shortcutRegistrar: some ShortcutRegistering = UIApplication.shared
    ) async {
        let person = Person(name: input.name, relationshipStart: input.startDate, gender: input.gender)
        if let photo = input.photo {
            let resized = await Task.detached {
                photo.resizedTo512()
            }.value
            person.photoData = resized.jpegData(compressionQuality: 0.8)
        }
        modelContext.insert(person)

        let anniversary = ImportantDate(
            title: String(localized: "Our Anniversary", comment: "Onboarding: auto-created anniversary event title"),
            date: input.startDate,
            recurrenceFrequency: .yearly,
            predefinedCategory: .anniversary,
            person: person
        )
        modelContext.insert(anniversary)

        if let trimmedLike = input.firstLike.nonBlank {
            let likeItem = LikeDislikeItem(
                name: trimmedLike,
                kind: .like,
                predefinedCategory: .other,
                person: person
            )
            modelContext.insert(likeItem)
        }

        WidgetDataService.sync(modelContext: modelContext, widgetReloader: widgetReloader)
        QuickActionService.registerShortcuts(using: shortcutRegistrar)
    }
}
