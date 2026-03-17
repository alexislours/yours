import SwiftData
import SwiftUI

struct ManageLikeDislikeCategoriesView: View {
    @Query(sort: \LikeDislikeCategory.createdAt) private var categories: [LikeDislikeCategory]

    var body: some View {
        ManageCategoriesContent<LikeDislikeCategory, LikeDislikePredefinedCategory>(
            categories: categories,
            config: .init(
                countLabel: { String(localized: "\($0) items", comment: "Category badge: like/dislike item count") },
                deleteMessage: "Items using this category will be moved to \"Other\".",
                placeholderText: "e.g. Flowers",
                onDeleteReassign: { category in
                    for item in category.items ?? [] {
                        item.customCategory = nil
                        item.predefinedCategory = .other
                    }
                },
                hiddenCategoriesKey: UserDefaultsKeys.hiddenLikeDislikeCategories
            )
        )
    }
}

#Preview {
    NavigationStack {
        ManageLikeDislikeCategoriesView()
    }
    .modelContainer(for: [LikeDislikeCategory.self, LikeDislikeItem.self, Person.self], inMemory: true)
}
