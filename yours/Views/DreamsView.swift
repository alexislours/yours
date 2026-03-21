import SwiftData
import SwiftUI

struct DreamsView: View {
    let person: Person
    var startWithNewDream: Bool = false

    var body: some View {
        InlineEditableListView(
            person: person,
            title: String(localized: "Dreams", comment: "Dreams: section title"),
            itemsKeyPath: \.dreams,
            textKeyPath: \.text,
            sortKeyPath: \.createdAt,
            searchPlaceholder: String(localized: "Search dreams", comment: "Dreams: search placeholder"),
            noResultsLabel: String(localized: "No dreams found", comment: "Dreams: no search results"),
            deleteConfirmationMessage: String(localized: "Delete dream?", comment: "Dreams: delete confirmation"),
            emptyStateIcon: "sparkles",
            emptyStateTitle: String(localized: "No dreams yet", comment: "Dreams: empty state title"),
            emptyStateDescription: String(
                localized: "The big goals, quiet hopes, and someday plans. Write them down so you can cheer them on.",
                comment: "Dreams: empty state description"
            ),
            emptyStateButtonLabel: String(localized: "Add a dream", comment: "Dreams: empty state button"),
            editorPlaceholder: String(localized: "A dream or aspiration...", comment: "Dreams: editor placeholder"),
            editorLineLimit: 1 ... 3,
            editorMaxLength: 280,
            editorWarningThreshold: 30,
            sortable: false,
            fabAccessibilityLabel: LocalizedStringResource("Add dream", comment: "Dreams: FAB accessibility label"),
            makeItem: { text, person in Dream(text: text, person: person) },
            onSaveEdit: nil,
            cardContent: { dream in
                HStack(alignment: .top) {
                    Text(dream.text)
                        .font(.custom(FontFamily.ui, size: 14, relativeTo: .subheadline))
                        .foregroundStyle(Color.textPrimary)
                        .lineSpacing(3)

                    Spacer(minLength: Spacing.md)

                    Text(dream.formattedDate)
                        .font(.caption)
                        .foregroundStyle(Color.textTertiary)
                        .layoutPriority(1)
                }
            },
            startWithNew: startWithNewDream
        )
    }
}

#Preview {
    DreamsView(person: .preview)
        .modelContainer(for: Person.self, inMemory: true)
}
