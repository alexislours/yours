import SwiftData
import SwiftUI

struct NotesView: View {
    let person: Person
    var startWithNewNote: Bool = false

    var body: some View {
        InlineEditableListView(
            person: person,
            title: "Notes",
            itemsKeyPath: \.notes,
            textKeyPath: \.body,
            sortKeyPath: \.createdAt,
            searchPlaceholder: "Search notes",
            noResultsLabel: "No notes found",
            deleteConfirmationMessage: "Delete note?",
            emptyStateIcon: "note.text",
            emptyStateTitle: "No notes yet",
            emptyStateDescription: """
            Thoughts, memories, things you want to remember about \
            \(person.firstName). Write them down so nothing slips away.
            """,
            emptyStateButtonLabel: "Write a note",
            editorPlaceholder: "What's on your mind?",
            editorLineLimit: 3 ... 20,
            editorMaxLength: nil,
            editorWarningThreshold: nil,
            sortable: true,
            fabAccessibilityLabel: "Add note",
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
