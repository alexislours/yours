import SwiftData
import SwiftUI

struct ManageAllergyCategoriesView: View {
    @Query(sort: \AllergyCategory.createdAt) private var categories: [AllergyCategory]

    var body: some View {
        ManageCategoriesContent<AllergyCategory, AllergyPredefinedCategory>(
            categories: categories,
            config: .init(
                countLabel: { String(localized: "\($0) items", comment: "Category badge: allergy item count") },
                deleteMessage: "Items using this category will be moved to \"Other\".",
                placeholderText: "e.g. Skincare",
                onDeleteReassign: { category in
                    for item in category.items ?? [] {
                        item.customCategory = nil
                        item.predefinedCategory = .other
                    }
                },
                hiddenCategoriesKey: UserDefaultsKeys.hiddenAllergyCategories
            )
        )
    }
}

#Preview {
    NavigationStack {
        ManageAllergyCategoriesView()
    }
    .modelContainer(for: [AllergyCategory.self, AllergyItem.self, Person.self], inMemory: true)
}
