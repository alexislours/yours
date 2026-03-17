import SwiftData
import SwiftUI

struct FoodOrderFormSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    let person: Person
    var existingItem: FoodOrderItem?
    let customCategories: [FoodOrderCategory]

    @State private var place = ""
    @State private var order = ""
    @State private var note = ""
    @State private var categoryState = CategoryFormState<FoodOrderPredefinedCategory, FoodOrderCategory>(
        defaultPredefined: .coffee
    )

    @FocusState private var focusedField: Field?

    private enum Field: Hashable {
        case place, order, note
    }

    private var isEditing: Bool {
        existingItem != nil
    }

    private var canSave: Bool {
        place.nonBlank != nil && order.nonBlank != nil
    }

    var body: some View {
        FormSheetWrapper(
            title: Text(isEditing
                ? String(localized: "Edit order", comment: "Food order form: sheet title when editing")
                : String(localized: "Add an order", comment: "Food order form: sheet title when adding")),
            canSave: canSave,
            onSave: save
        ) {
            placeField
            orderField
            categoryPicker
            noteField
        }
        .onAppear(perform: populateFromExisting)
        .sheet(isPresented: $categoryState.showManageCategories) {
            NavigationStack {
                ManageFoodOrderCategoriesView()
            }
        }
    }

    // MARK: - Place

    private var placeField: some View {
        FormField(
            String(localized: "Place", comment: "Food order form: field label for the restaurant or venue"),
            isFocused: focusedField == .place
        ) {
            TextField(
                String(localized: "Restaurant, cafe, bar...", comment: "Food order form: placeholder for restaurant or venue name"),
                text: $place
            )
            .font(.bodyDefault)
            .foregroundStyle(Color.textPrimary)
            .focused($focusedField, equals: .place)
        }
    }

    // MARK: - Order

    private var orderField: some View {
        FormField(
            String(localized: "Order", comment: "Food order form: field label for the order details"),
            isFocused: focusedField == .order
        ) {
            TextField(
                String(localized: "What they get...", comment: "Food order form: placeholder for the order details"),
                text: $order,
                axis: .vertical
            )
            .font(.bodyDefault)
            .foregroundStyle(Color.textPrimary)
            .lineLimit(2 ... 5)
            .focused($focusedField, equals: .order)
        }
    }

    // MARK: - Category

    private var categoryPicker: some View {
        CategoryPickerSection(
            title: String(localized: "Category", comment: "Category picker: section title"),
            predefinedCategories: FoodOrderPredefinedCategory.allCases.filter { $0 != .other },
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
        FormField(String(localized: "Notes (optional)", comment: "Form field: optional notes label"), isFocused: focusedField == .note) {
            TextField(
                String(
                    localized: "Oat milk, no onions, extra spicy...",
                    comment: "Food order form: placeholder for order notes and preferences"
                ),
                text: $note
            )
            .font(.bodyDefault)
            .foregroundStyle(Color.textPrimary)
            .focused($focusedField, equals: .note)
        }
    }

    // MARK: - Actions

    private func populateFromExisting() {
        guard let existing = existingItem else { return }
        place = existing.place
        order = existing.order
        note = existing.note ?? ""
        categoryState.populate(customCategory: existing.customCategory, predefined: existing.predefinedCategory)
    }

    private func save() {
        FoodOrderService.save(.init(
            existing: existingItem,
            place: place,
            order: order,
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
    FoodOrderFormSheet(person: .preview, customCategories: [])
        .modelContainer(for: [Person.self, FoodOrderItem.self, FoodOrderCategory.self], inMemory: true)
}
