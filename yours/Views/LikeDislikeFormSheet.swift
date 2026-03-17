import SwiftData
import SwiftUI

struct LikeDislikeFormSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    let person: Person
    let kind: LikesDislikesListView.Kind
    var existingItem: LikeDislikeItem?
    let customCategories: [LikeDislikeCategory]
    let hiddenCategoriesRaw: String

    @State private var name = ""
    @State private var note = ""
    @State private var categoryState = CategoryFormState<LikeDislikePredefinedCategory, LikeDislikeCategory>(
        defaultPredefined: .other
    )

    @FocusState private var focusedField: Field?

    private enum Field: Hashable {
        case name, note
    }

    private var isEditing: Bool {
        existingItem != nil
    }

    private var canSave: Bool {
        name.nonBlank != nil
    }

    private var categoryVisibility: (visible: [LikeDislikePredefinedCategory], hidden: [LikeDislikePredefinedCategory]) {
        LikeDislikePredefinedCategory.filterByVisibility(hiddenRaw: hiddenCategoriesRaw)
    }

    var body: some View {
        FormSheetWrapper(
            title: Text(isEditing
                // swiftlint:disable:next line_length
                ? String(localized: "Edit \(kind.title.lowercased())", comment: "Like/dislike form: sheet title when editing, e.g. 'Edit like' or 'Edit dislike'")
                // swiftlint:disable:next line_length
                : String(localized: "Add a \(kind.title.lowercased())", comment: "Like/dislike form: sheet title when adding, e.g. 'Add a like' or 'Add a dislike'")),
            canSave: canSave,
            onSave: save
        ) {
            nameField
            categoryPicker
            noteField
        }
        .onAppear(perform: populateFromExisting)
        .sheet(isPresented: $categoryState.showManageCategories) {
            NavigationStack {
                ManageLikeDislikeCategoriesView()
            }
        }
    }

    // MARK: - Name

    private var nameField: some View {
        FormField(String(localized: "Name", comment: "Form field: item name label"), isFocused: focusedField == .name) {
            TextField(kind.placeholder, text: $name)
                .font(.bodyDefault)
                .foregroundStyle(Color.textPrimary)
                .focused($focusedField, equals: .name)
        }
    }

    // MARK: - Category

    private var categoryPicker: some View {
        CategoryPickerSection(
            title: String(localized: "Category", comment: "Category picker: section title"),
            predefinedCategories: categoryVisibility.visible,
            customCategories: customCategories,
            hiddenCategories: categoryVisibility.hidden,
            useCustomCategory: categoryState.useCustomCategory,
            selectedPredefined: categoryState.selectedPredefined,
            selectedCustomID: categoryState.selectedCustomCategory?.id,
            predefinedDisplay: { CategoryDisplayInfo(label: $0.displayName, icon: $0.icon, color: $0.color) },
            customDisplay: { CategoryDisplayInfo(label: $0.name, icon: $0.sfSymbol, color: $0.color) },
            onSelectPredefined: categoryState.selectPredefined,
            onSelectCustom: categoryState.selectCustom,
            onManage: { categoryState.showManageCategories = true }
        )
    }

    // MARK: - Note

    private var noteField: some View {
        FormField(String(localized: "Note (optional)", comment: "Form field: optional note label"), isFocused: focusedField == .note) {
            TextField(
                String(localized: "Any details to remember", comment: "Form field: placeholder for optional note"),
                text: $note,
                axis: .vertical
            )
            .font(.bodyDefault)
            .foregroundStyle(Color.textPrimary)
            .lineLimit(2 ... 5)
            .focused($focusedField, equals: .note)
        }
    }

    // MARK: - Actions

    private func populateFromExisting() {
        guard let existing = existingItem else { return }
        name = existing.name
        note = existing.note ?? ""
        categoryState.populate(customCategory: existing.customCategory, predefined: existing.predefinedCategory)
    }

    private func save() {
        LikeDislikeService.save(.init(
            existing: existingItem,
            name: name,
            note: note,
            kind: kind.itemKind,
            useCustomCategory: categoryState.useCustomCategory,
            selectedPredefined: categoryState.selectedPredefined,
            selectedCustomCategory: categoryState.selectedCustomCategory,
            person: person
        ), in: modelContext)
        dismiss()
    }
}

#Preview {
    LikeDislikeFormSheet(person: .preview, kind: .likes, customCategories: [], hiddenCategoriesRaw: "")
        .modelContainer(for: [Person.self, LikeDislikeItem.self, LikeDislikeCategory.self], inMemory: true)
}
