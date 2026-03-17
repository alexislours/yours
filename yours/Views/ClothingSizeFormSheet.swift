import SwiftData
import SwiftUI

struct ClothingSizeFormSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    let person: Person
    var existingItem: ClothingSizeItem?
    let customCategories: [ClothingSizeCategory]

    @State private var size = ""
    @State private var note = ""
    @State private var categoryState = CategoryFormState<ClothingSizePredefinedCategory, ClothingSizeCategory>(
        defaultPredefined: .tops
    )
    @State private var showDeleteConfirm = false
    @FocusState private var focusedField: Field?

    private enum Field: Hashable {
        case size, note
    }

    private var isEditing: Bool {
        existingItem != nil
    }

    private var canSave: Bool {
        size.nonBlank != nil
    }

    /// Categories that already have a size entry (exclude current editing item's category).
    private var usedCategoryKeys: Set<String> {
        var keys = Set<String>()
        for item in person.clothingSizeItems ?? [] {
            if let existing = existingItem, item.id == existing.id { continue }
            keys.insert(item.categoryGroupKey)
        }
        return keys
    }

    /// Only show predefined categories that don't already have a size.
    private var availablePredefined: [ClothingSizePredefinedCategory] {
        ClothingSizePredefinedCategory.allCases.filter { !usedCategoryKeys.contains($0.rawValue) }
    }

    /// Only show custom categories that don't already have a size.
    private var availableCustom: [ClothingSizeCategory] {
        customCategories.filter { cat in
            !usedCategoryKeys.contains("custom:\(cat.persistentModelID)")
        }
    }

    private var currentPlaceholder: String {
        if categoryState.useCustomCategory {
            return "Enter size..."
        }
        return categoryState.selectedPredefined.placeholder
    }

    var body: some View {
        FormSheetWrapper(
            title: Text(isEditing
                ? String(localized: "Edit size", comment: "Size form: sheet title when editing")
                : String(localized: "Add a size", comment: "Size form: sheet title when adding")),
            canSave: canSave,
            onSave: save
        ) {
            categoryPicker
            sizeField
            noteField

            if isEditing {
                deleteButton
            }
        }
        .onAppear(perform: populateFromExisting)
        .sheet(isPresented: $categoryState.showManageCategories) {
            NavigationStack {
                ManageClothingSizeCategoriesView()
            }
        }
        .deleteConfirmation(
            String(localized: "Delete size?", comment: "Delete confirmation: title for deleting a clothing size"),
            isPresented: $showDeleteConfirm
        ) {
            if let item = existingItem {
                modelContext.delete(item)
            }
            dismiss()
        }
    }

    // MARK: - Category Picker

    private var categoryPicker: some View {
        CategoryPickerSection(
            title: String(localized: "Category", comment: "Category picker: section title"),
            predefinedCategories: availablePredefined,
            customCategories: availableCustom,
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

    // MARK: - Size Field

    private var sizeField: some View {
        FormField(String(localized: "Size", comment: "Size form: field label for the size value"), isFocused: focusedField == .size) {
            TextField(currentPlaceholder, text: $size)
                .font(.bodyDefault)
                .foregroundStyle(Color.textPrimary)
                .focused($focusedField, equals: .size)
        }
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

    // MARK: - Delete Button

    private var deleteButton: some View {
        Button(action: { showDeleteConfirm = true }, label: {
            HStack {
                Spacer()
                Text(String(localized: "Delete size", comment: "Size form: destructive button to delete a clothing size"))
                    .font(.label)
                    .foregroundStyle(Color.error)
                Spacer()
            }
            .padding(.vertical, Spacing.md)
            .background(Color.errorSoft, in: RoundedRectangle(cornerRadius: CornerRadius.md))
        })
        .buttonStyle(.plain)
    }

    // MARK: - Actions

    private func populateFromExisting() {
        guard let existing = existingItem else { return }
        size = existing.size
        note = existing.note ?? ""
        categoryState.populate(customCategory: existing.customCategory, predefined: existing.predefinedCategory)
    }

    private func save() {
        ClothingSizeService.save(.init(
            existing: existingItem,
            size: size,
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
    ClothingSizeFormSheet(person: .preview, customCategories: [])
        .modelContainer(for: [Person.self, ClothingSizeItem.self, ClothingSizeCategory.self], inMemory: true)
}
