import SwiftData
import SwiftUI

struct ManageClothingSizeCategoriesView: View {
    @Query(sort: \ClothingSizeCategory.createdAt) private var categories: [ClothingSizeCategory]

    var body: some View {
        ManageCategoriesContent<ClothingSizeCategory, ClothingSizePredefinedCategory>(
            categories: categories,
            config: .init(
                countLabel: { String(localized: "\($0) sizes", comment: "Category badge: clothing size count") },
                deleteMessage: "Items using this category will be moved to \"Other\".",
                placeholderText: "e.g. Hats",
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
        ManageClothingSizeCategoriesView()
    }
    .modelContainer(for: [ClothingSizeCategory.self, ClothingSizeItem.self, Person.self], inMemory: true)
}
