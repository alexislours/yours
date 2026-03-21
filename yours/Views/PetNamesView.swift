import SwiftData
import SwiftUI

struct PetNamesView: View {
    let person: Person
    var startWithNewPetName: Bool = false

    var body: some View {
        InlineEditableListView(
            person: person,
            title: String(localized: "Pet Names", comment: "Pet names: section title"),
            itemsKeyPath: \.petNames,
            textKeyPath: \.text,
            sortKeyPath: \.createdAt,
            searchPlaceholder: String(localized: "Search pet names", comment: "Pet names: search placeholder"),
            noResultsLabel: String(localized: "No pet names found", comment: "Pet names: no search results"),
            deleteConfirmationMessage: String(localized: "Delete pet name?", comment: "Pet names: delete confirmation"),
            emptyStateIcon: "heart.text.clipboard",
            emptyStateTitle: String(localized: "No pet names yet", comment: "Pet names: empty state title"),
            emptyStateDescription: String(
                localized: "The silly, sweet, and secret names only you two use. Save them here so you never forget.",
                comment: "Pet names: empty state description"
            ),
            emptyStateButtonLabel: String(localized: "Add a pet name", comment: "Pet names: empty state button"),
            editorPlaceholder: String(localized: "A name only you use...", comment: "Pet names: editor placeholder"),
            editorLineLimit: 1 ... 3,
            editorMaxLength: 100,
            editorWarningThreshold: 15,
            sortable: false,
            fabAccessibilityLabel: LocalizedStringResource("Add pet name", comment: "Pet names: FAB accessibility label"),
            makeItem: { text, person in PetName(text: text, person: person) },
            onSaveEdit: nil,
            cardContent: { petName in
                HStack(alignment: .top) {
                    Text(petName.text)
                        .font(.custom(FontFamily.ui, size: 14, relativeTo: .subheadline))
                        .foregroundStyle(Color.textPrimary)
                        .lineSpacing(3)

                    Spacer(minLength: Spacing.md)

                    Text(petName.formattedDate)
                        .font(.caption)
                        .foregroundStyle(Color.textTertiary)
                        .layoutPriority(1)
                }
            },
            startWithNew: startWithNewPetName
        )
    }
}

#Preview {
    PetNamesView(person: .preview)
        .modelContainer(for: Person.self, inMemory: true)
}
