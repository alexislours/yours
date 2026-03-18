import SwiftData
import SwiftUI

struct QuirksView: View {
    let person: Person
    var startWithNewQuirk: Bool = false

    var body: some View {
        InlineEditableListView(
            person: person,
            title: String(localized: "Quirks & Habits", comment: "Quirks: section title"),
            itemsKeyPath: \.quirks,
            textKeyPath: \.text,
            sortKeyPath: \.createdAt,
            searchPlaceholder: String(localized: "Search quirks", comment: "Quirks: search placeholder"),
            noResultsLabel: String(localized: "No quirks found", comment: "Quirks: no search results"),
            deleteConfirmationMessage: String(localized: "Delete quirk?", comment: "Quirks: delete confirmation"),
            emptyStateIcon: "eyes",
            emptyStateTitle: String(localized: "No quirks yet", comment: "Quirks: empty state title"),
            emptyStateDescription: String(
                localized: "The little things you notice. The way they laugh, what they always order, the habits only you'd pick up on.",
                comment: "Quirks: empty state description"
            ),
            emptyStateButtonLabel: String(localized: "Add a quirk", comment: "Quirks: empty state button"),
            editorPlaceholder: String(localized: "Something you've noticed...", comment: "Quirks: editor placeholder"),
            editorLineLimit: 1 ... 6,
            editorMaxLength: 280,
            editorWarningThreshold: 30,
            sortable: false,
            fabAccessibilityLabel: LocalizedStringResource("Add quirk", comment: "Quirks: FAB accessibility label"),
            makeItem: { text, person in Quirk(text: text, person: person) },
            onSaveEdit: nil,
            cardContent: { quirk in
                HStack(alignment: .top) {
                    Text(quirk.text)
                        .font(.custom(FontFamily.ui, size: 14, relativeTo: .subheadline))
                        .foregroundStyle(Color.textPrimary)
                        .lineSpacing(3)

                    Spacer(minLength: Spacing.md)

                    Text(quirk.formattedDate)
                        .font(.caption)
                        .foregroundStyle(Color.textTertiary)
                        .layoutPriority(1)
                }
            },
            startWithNew: startWithNewQuirk
        )
    }
}

#Preview {
    QuirksView(person: .preview)
        .modelContainer(for: Person.self, inMemory: true)
}
