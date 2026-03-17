import SwiftData
import SwiftUI

struct TheirPeopleFormSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    let person: Person
    var existingItem: TheirPeopleItem?
    let customCategories: [TheirPeopleCategory]

    @State private var name = ""
    @State private var note = ""
    @State private var categoryState = CategoryFormState<TheirPeoplePredefinedCategory, TheirPeopleCategory>(
        defaultPredefined: .friend
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

    var body: some View {
        FormSheetWrapper(
            title: Text(isEditing
                ? String(localized: "Edit person", comment: "People form: sheet title when editing")
                : String(localized: "Add a person", comment: "People form: sheet title when adding")),
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
                ManageTheirPeopleCategoriesView()
            }
        }
    }

    // MARK: - Name

    private var nameField: some View {
        FormField(String(localized: "Name", comment: "Form field: person's name label"), isFocused: focusedField == .name) {
            TextField("Their name", text: $name)
                .font(.bodyDefault)
                .foregroundStyle(Color.textPrimary)
                .focused($focusedField, equals: .name)
        }
    }

    // MARK: - Category

    private var categoryPicker: some View {
        CategoryPickerSection(
            title: String(localized: "Relationship", comment: "Category picker: relationship type section title"),
            predefinedCategories: Array(TheirPeoplePredefinedCategory.allCases),
            customCategories: customCategories,
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
                String(localized: "e.g. Lives in Portland", comment: "Their people form: placeholder for optional note about a person"),
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
        TheirPeopleService.save(.init(
            existing: existingItem,
            name: name,
            note: note,
            useCustomCategory: categoryState.useCustomCategory,
            selectedPredefined: categoryState.selectedPredefined,
            selectedCustomCategory: categoryState.selectedCustomCategory,
            person: person
        ), in: modelContext)
        dismiss()
    }
}

#Preview {
    TheirPeopleFormSheet(person: .preview, customCategories: [])
        .modelContainer(for: [Person.self, TheirPeopleItem.self, TheirPeopleCategory.self], inMemory: true)
}
