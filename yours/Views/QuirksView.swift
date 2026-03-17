import SwiftData
import SwiftUI

struct QuirksView: View {
    let person: Person
    var startWithNewQuirk: Bool = false

    var body: some View {
        InlineEditableListView(
            person: person,
            title: "Quirks & Habits",
            itemsKeyPath: \.quirks,
            textKeyPath: \.text,
            sortKeyPath: \.createdAt,
            searchPlaceholder: "Search quirks",
            noResultsLabel: "No quirks found",
            deleteConfirmationMessage: "Delete quirk?",
            emptyStateIcon: "eyes",
            emptyStateTitle: "No quirks yet",
            emptyStateDescription: """
            The little things you notice. The way they laugh, \
            what they always order, the habits only you'd pick up on.
            """,
            emptyStateButtonLabel: "Add a quirk",
            editorPlaceholder: "Something you've noticed...",
            editorLineLimit: 1 ... 6,
            editorMaxLength: 280,
            editorWarningThreshold: 30,
            sortable: false,
            fabAccessibilityLabel: "Add quirk",
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
