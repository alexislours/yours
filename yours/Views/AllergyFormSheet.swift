import SwiftData
import SwiftUI

struct AllergyFormSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    let person: Person
    var existingItem: AllergyItem?
    let customCategories: [AllergyCategory]
    let hiddenCategoriesRaw: String

    @State private var name = ""
    @State private var note = ""
    @State private var categoryState = CategoryFormState<AllergyPredefinedCategory, AllergyCategory>(
        defaultPredefined: .food
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

    private var categoryVisibility: (visible: [AllergyPredefinedCategory], hidden: [AllergyPredefinedCategory]) {
        AllergyPredefinedCategory.filterByVisibility(hiddenRaw: hiddenCategoriesRaw)
    }

    var body: some View {
        FormSheetWrapper(
            title: Text(isEditing
                ? String(localized: "Edit allergy", comment: "Allergy form: sheet title when editing")
                : String(localized: "Add an allergy", comment: "Allergy form: sheet title when adding")),
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
                ManageAllergyCategoriesView()
            }
        }
    }

    // MARK: - Name

    private var nameField: some View {
        FormField(String(localized: "Name", comment: "Form field: item name label"), isFocused: focusedField == .name) {
            TextField(
                String(localized: "Something they're allergic to...", comment: "Allergy form: placeholder for allergy name"),
                text: $name
            )
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
        AllergyService.save(.init(
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
    AllergyFormSheet(person: .preview, customCategories: [], hiddenCategoriesRaw: "")
        .modelContainer(for: [Person.self, AllergyItem.self, AllergyCategory.self], inMemory: true)
}
