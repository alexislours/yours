import SwiftData
import SwiftUI

struct ManageGiftCategoriesView: View {
    @Query(sort: \GiftCategory.createdAt) private var categories: [GiftCategory]

    var body: some View {
        ManageCategoriesContent<GiftCategory, GiftOccasion>(
            categories: categories,
            config: .init(
                headerTitle: "Gift categories",
                countLabel: { String(localized: "\($0) ideas", comment: "Category badge: gift idea count") },
                deleteMessage: "Ideas using this category will be moved to \"Just Because\".",
                placeholderText: "e.g. Gadgets",
                onDeleteReassign: { category in
                    for idea in category.giftIdeas ?? [] {
                        idea.customCategory = nil
                        idea.predefinedCategory = .justBecause
                    }
                }
            )
        )
    }
}

#Preview {
    NavigationStack {
        ManageGiftCategoriesView()
    }
    .modelContainer(for: [GiftCategory.self, GiftIdea.self, Person.self], inMemory: true)
}
