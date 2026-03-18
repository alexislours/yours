import SwiftData
import SwiftUI

struct ManageGiftCategoriesView: View {
    @Query(sort: \GiftCategory.createdAt) private var categories: [GiftCategory]

    var body: some View {
        ManageCategoriesContent<GiftCategory, GiftOccasion>(
            categories: categories,
            config: .init(
                headerTitle: String(localized: "Gift categories", comment: "Gift categories: section header"),
                countLabel: { String(localized: "\($0) ideas", comment: "Category badge: gift idea count") },
                deleteMessage: String(
                    localized: "Ideas using this category will be moved to \"Just Because\".",
                    comment: "Gift categories: delete warning"
                ),
                placeholderText: String(localized: "e.g. Gadgets", comment: "Gift categories: new category placeholder"),
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
