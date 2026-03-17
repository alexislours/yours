import SwiftData
import SwiftUI

struct ManageTheirPeopleCategoriesView: View {
    @Query(sort: \TheirPeopleCategory.createdAt) private var categories: [TheirPeopleCategory]

    var body: some View {
        ManageCategoriesContent<TheirPeopleCategory, TheirPeoplePredefinedCategory>(
            categories: categories,
            config: .init(
                countLabel: { String(localized: "\($0) people", comment: "Category badge: people count") },
                deleteMessage: "People using this category will be moved to \"Other\".",
                placeholderText: "e.g. Neighbor",
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
        ManageTheirPeopleCategoriesView()
    }
    .modelContainer(for: [TheirPeopleCategory.self, TheirPeopleItem.self, Person.self], inMemory: true)
}
