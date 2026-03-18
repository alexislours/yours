import SwiftData
import SwiftUI

struct NotesView: View {
    let person: Person
    var startWithNewNote: Bool = false

    var body: some View {
        InlineEditableListView(
            person: person,
            title: String(localized: "Notes", comment: "Notes: section title"),
            itemsKeyPath: \.notes,
            textKeyPath: \.body,
            sortKeyPath: \.createdAt,
            searchPlaceholder: String(localized: "Search notes", comment: "Notes: search placeholder"),
            noResultsLabel: String(localized: "No notes found", comment: "Notes: no search results"),
            deleteConfirmationMessage: String(localized: "Delete note?", comment: "Notes: delete confirmation"),
            emptyStateIcon: "note.text",
            emptyStateTitle: String(localized: "No notes yet", comment: "Notes: empty state title"),
            emptyStateDescription: String(
                localized: """
                Thoughts, memories, things you want to remember \
                about \(person.firstName). Write them down so \
                nothing slips away.
                """,
                comment: "Notes: empty state description"
            ),
            emptyStateButtonLabel: String(localized: "Write a note", comment: "Notes: empty state button"),
            editorPlaceholder: String(localized: "What's on your mind?", comment: "Notes: editor placeholder"),
            editorLineLimit: 3 ... 20,
            editorMaxLength: nil,
            editorWarningThreshold: nil,
            sortable: true,
            fabAccessibilityLabel: LocalizedStringResource("Add note", comment: "Notes: FAB accessibility label"),
            makeItem: { text, person in Note(body: text, person: person) },
            onSaveEdit: { note in note.updatedAt = .now },
            cardContent: { note in
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text(note.body)
                        .font(.custom(FontFamily.ui, size: 14, relativeTo: .subheadline))
                        .foregroundStyle(Color.textPrimary)
                        .lineSpacing(3)

                    Text(note.formattedDate)
                        .font(.caption)
                        .foregroundStyle(Color.textTertiary)
                }
            },
            startWithNew: startWithNewNote
        )
    }
}

#Preview {
    NotesView(person: .preview)
        .modelContainer(for: Person.self, inMemory: true)
}
