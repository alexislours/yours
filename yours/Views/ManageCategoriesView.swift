import SwiftData
import SwiftUI

struct ManageCategoriesView: View {
    @Query(sort: \DateCategory.createdAt) private var categories: [DateCategory]

    var body: some View {
        ManageCategoriesContent<DateCategory, ImportantDatePredefinedCategory>(
            categories: categories,
            config: .init(
                countLabel: { String(localized: "\($0) dates", comment: "Category badge: date count") },
                deleteMessage: "Dates using this category will be moved to \"Other\".",
                placeholderText: "e.g. Travel",
                onDeleteReassign: { category in
                    for date in category.dates ?? [] {
                        date.customCategory = nil
                        date.predefinedCategory = .other
                    }
                }
            )
        )
    }
}

#Preview {
    NavigationStack {
        ManageCategoriesView()
    }
    .modelContainer(for: [DateCategory.self, ImportantDate.self, Person.self], inMemory: true)
}
