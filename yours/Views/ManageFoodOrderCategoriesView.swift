import SwiftData
import SwiftUI

struct ManageFoodOrderCategoriesView: View {
    @Query(sort: \FoodOrderCategory.createdAt) private var categories: [FoodOrderCategory]

    var body: some View {
        ManageCategoriesContent<FoodOrderCategory, FoodOrderPredefinedCategory>(
            categories: categories,
            config: .init(
                countLabel: { String(localized: "\($0) items", comment: "Category badge: food order item count") },
                deleteMessage: "Items using this category will be moved to \"Other\".",
                placeholderText: "e.g. Brunch",
                onDeleteReassign: { category in
                    for item in category.items ?? [] {
                        item.customCategory = nil
                        item.predefinedCategory = .other
                    }
                }
            )
        )
    }
}

#Preview {
    NavigationStack {
        ManageFoodOrderCategoriesView()
    }
    .modelContainer(for: [FoodOrderCategory.self, FoodOrderItem.self, Person.self], inMemory: true)
}
