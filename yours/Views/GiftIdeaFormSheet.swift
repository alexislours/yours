import SwiftData
import SwiftUI

struct GiftIdeaFormSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    let person: Person
    var existingIdea: GiftIdea?
    let customCategories: [GiftCategory]

    @State private var title = ""
    @State private var note = ""
    @State private var priceText = ""
    @State private var urlString = ""
    @State private var selectedPredefined: GiftOccasion = .justBecause
    @State private var selectedCustomCategory: GiftCategory?
    @State private var useCustomCategory = false
    @State private var selectedLinkedDate: ImportantDate?
    @State private var showManageCategories = false
    @State private var showLinkedDatePicker = false
    @FocusState private var focusedField: Field?

    private enum Field: Hashable {
        case title, note, price, url
    }

    private var isEditing: Bool {
        existingIdea != nil
    }

    private var canSave: Bool {
        title.nonBlank != nil
    }

    private var parsedPrice: Decimal? {
        guard let cleaned = priceText.nonBlank else { return nil }
        return Decimal(string: cleaned)
    }

    var body: some View {
        FormSheetWrapper(
            title: Text(isEditing
                ? String(localized: "Edit idea", comment: "Gift form: sheet title when editing")
                : String(localized: "Add an idea", comment: "Gift form: sheet title when adding")),
            canSave: canSave,
            detents: [.large],
            onSave: save
        ) {
            titleField
            categoryPicker
            noteField
            priceField
            urlField
            linkedDatePicker
        }
        .onAppear(perform: populateFromExisting)
        .sheet(isPresented: $showManageCategories) {
            NavigationStack {
                ManageGiftCategoriesView()
            }
        }
        .sheet(isPresented: $showLinkedDatePicker) {
            LinkedDatePickerSheet(
                dates: person.importantDates ?? [],
                selection: $selectedLinkedDate
            )
        }
    }

    // MARK: - Title

    private var titleField: some View {
        FormField(String(localized: "Title", comment: "Form field: item title label"), isFocused: focusedField == .title) {
            TextField(
                String(localized: "e.g. Vintage Polaroid camera", comment: "Gift form: placeholder for gift idea title"),
                text: $title
            )
            .font(.bodyDefault)
            .foregroundStyle(Color.textPrimary)
            .focused($focusedField, equals: .title)
        }
    }

    // MARK: - Category

    private var categoryPicker: some View {
        CategoryPickerSection(
            title: String(localized: "Occasion", comment: "Category picker: gift occasion section title"),
            predefinedCategories: Array(GiftOccasion.allCases),
            customCategories: customCategories,
            useCustomCategory: useCustomCategory,
            selectedPredefined: selectedPredefined,
            selectedCustomID: selectedCustomCategory?.id,
            predefinedDisplay: { CategoryDisplayInfo(label: $0.displayName, icon: $0.icon, color: $0.color) },
            customDisplay: { CategoryDisplayInfo(label: $0.name, icon: $0.sfSymbol, color: $0.color) },
            onSelectPredefined: { occasion in
                useCustomCategory = false
                selectedPredefined = occasion
                selectedCustomCategory = nil
            },
            onSelectCustom: { cat in
                useCustomCategory = true
                selectedCustomCategory = cat
            },
            onManage: { showManageCategories = true }
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

    // MARK: - Price

    private var priceField: some View {
        FormField(
            String(localized: "Price (optional)", comment: "Gift form: optional price field label"),
            isFocused: focusedField == .price
        ) {
            HStack(spacing: Spacing.sm) {
                Text(currencySymbol)
                    .font(.bodyDefault)
                    .foregroundStyle(Color.textTertiary)

                TextField(String(localized: "0.00", comment: "Gift form: placeholder for price input"), text: $priceText)
                    .font(.bodyDefault)
                    .foregroundStyle(Color.textPrimary)
                    .keyboardType(.decimalPad)
                    .focused($focusedField, equals: .price)
            }
        }
    }

    private var currencySymbol: String {
        CurrencyFormatting.preferredCurrencySymbol
    }

    // MARK: - URL

    private var urlField: some View {
        FormField(
            String(localized: "Link (optional)", comment: "Gift form: optional URL link field label"),
            isFocused: focusedField == .url
        ) {
            TextField(String(localized: "e.g. amazon.com/...", comment: "Gift form: placeholder for product URL"), text: $urlString)
                .font(.bodyDefault)
                .foregroundStyle(Color.textPrimary)
                .keyboardType(.URL)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .focused($focusedField, equals: .url)
        }
    }

    // MARK: - Linked Date

    private var linkedDatePicker: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text(String(localized: "Linked date (optional)", comment: "Gift form: section label for linking a gift to a date"))
                .font(.sectionLabel)
                .foregroundStyle(Color.textTertiary)

            let dates = person.importantDates ?? []

            if dates.isEmpty {
                Text(String(localized: "No important dates to link", comment: "Gift form: shown when person has no dates to link"))
                    .font(.bodySmall)
                    .foregroundStyle(Color.textTertiary)
                    .padding(.horizontal, Spacing.lg)
                    .padding(.vertical, Spacing.md)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.bgSurface)
                    .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
                    .overlay(
                        RoundedRectangle(cornerRadius: CornerRadius.md)
                            .strokeBorder(Color.borderSubtle, lineWidth: 1)
                    )
            } else {
                Button(action: { showLinkedDatePicker = true }, label: {
                    HStack {
                        if let linked = selectedLinkedDate {
                            Image(systemName: linked.categoryIcon)
                                .font(.custom(FontFamily.ui, size: 12, relativeTo: .caption))
                                .foregroundStyle(linked.categoryColor)

                            Text(linked.title)
                                .font(.custom(FontFamily.ui, size: 14, relativeTo: .subheadline))
                                .fontWeight(.medium)
                                .foregroundStyle(Color.textPrimary)
                        } else {
                            Text(String(localized: "None", comment: "Gift form: placeholder when no date is linked"))
                                .font(.custom(FontFamily.ui, size: 14, relativeTo: .subheadline))
                                .fontWeight(.medium)
                                .foregroundStyle(Color.textTertiary)
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.custom(FontFamily.ui, size: 12, relativeTo: .caption).weight(.medium))
                            .foregroundStyle(Color.textTertiary)
                            .accessibilityHidden(true)
                    }
                    .padding(.horizontal, Spacing.lg)
                    .padding(.vertical, Spacing.md)
                    .background(Color.bgSurface)
                    .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
                    .overlay(
                        RoundedRectangle(cornerRadius: CornerRadius.md)
                            .strokeBorder(Color.borderSubtle, lineWidth: 1)
                    )
                })
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Actions

    private func populateFromExisting() {
        guard let existing = existingIdea else { return }
        title = existing.title
        note = existing.note ?? ""
        if let price = existing.price {
            priceText = "\(price)"
        }
        urlString = existing.urlString ?? ""
        selectedLinkedDate = existing.linkedDate
        if let custom = existing.customCategory {
            useCustomCategory = true
            selectedCustomCategory = custom
        } else {
            selectedPredefined = existing.predefinedCategory
        }
    }

    private func save() {
        GiftIdeaService.save(.init(
            existing: existingIdea,
            title: title,
            note: note,
            price: parsedPrice,
            urlString: urlString,
            useCustomCategory: useCustomCategory,
            selectedPredefined: selectedPredefined,
            selectedCustomCategory: selectedCustomCategory,
            linkedDate: selectedLinkedDate,
            person: person
        ), in: modelContext)
        dismiss()
    }
}

#Preview {
    GiftIdeaFormSheet(person: .preview, customCategories: [])
        .modelContainer(for: [Person.self, GiftIdea.self, GiftCategory.self, ImportantDate.self], inMemory: true)
}
