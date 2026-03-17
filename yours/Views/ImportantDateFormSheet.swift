import SwiftData
import SwiftUI

struct ImportantDateFormSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    let person: Person
    var existingDate: ImportantDate?
    let customCategories: [DateCategory]

    @State private var title = ""
    @State private var date = Date.now
    @State private var note = ""
    @State private var recurrenceFrequency: RecurrenceFrequency = .never
    @State private var selectedPredefined: ImportantDatePredefinedCategory = .birthday
    @State private var selectedCustomCategory: DateCategory?
    @State private var useCustomCategory = false
    @State private var showManageCategories = false
    @State private var reminderEnabled = false
    @State private var reminderDaysBefore = 1
    @FocusState private var focusedField: Field?

    private enum Field: Hashable {
        case title, note
    }

    private var isEditing: Bool {
        existingDate != nil
    }

    private var canSave: Bool {
        title.nonBlank != nil
    }

    var body: some View {
        FormSheetWrapper(
            title: Text(isEditing
                ? String(localized: "Edit date", comment: "Date form: sheet title when editing an existing date")
                : String(localized: "Add a date", comment: "Date form: sheet title when adding a new date")),
            canSave: canSave,
            detents: [.large],
            onSave: save
        ) {
            titleField
            dateField
            categoryPicker
            noteField
            recurrenceSection
            reminderSection
        }
        .accessibilityIdentifier("sheet-date-form")
        .onAppear(perform: populateFromExisting)
        .sheet(isPresented: $showManageCategories) {
            NavigationStack {
                ManageCategoriesView()
            }
        }
    }

    // MARK: - Title

    private var titleField: some View {
        FormField(String(localized: "Title", comment: "Form field: item title label"), isFocused: focusedField == .title) {
            TextField(String(localized: "e.g. Mom's birthday", comment: "Date form: placeholder for date title"), text: $title)
                .font(.bodyDefault)
                .foregroundStyle(Color.textPrimary)
                .focused($focusedField, equals: .title)
                .accessibilityIdentifier("field-date-title")
        }
    }

    // MARK: - Date

    private var dateField: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text(String(localized: "Date", comment: "Date form: date picker section label"))
                .font(.sectionLabel)
                .foregroundStyle(Color.textTertiary)

            DatePicker(
                selection: $date,
                displayedComponents: .date
            ) {}
                .datePickerStyle(.graphical)
                .tint(Color.accentPrimary)
                .padding(Spacing.md)
                .background(Color.bgSurface)
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
                .overlay(
                    RoundedRectangle(cornerRadius: CornerRadius.md)
                        .strokeBorder(Color.borderSubtle, lineWidth: 1)
                )
        }
    }

    // MARK: - Category

    private var categoryPicker: some View {
        CategoryPickerSection(
            title: String(localized: "Category", comment: "Category picker: section title"),
            predefinedCategories: Array(ImportantDatePredefinedCategory.allCases),
            customCategories: customCategories,
            useCustomCategory: useCustomCategory,
            selectedPredefined: selectedPredefined,
            selectedCustomID: selectedCustomCategory?.id,
            predefinedDisplay: { CategoryDisplayInfo(label: $0.displayName, icon: $0.icon, color: $0.color) },
            customDisplay: { CategoryDisplayInfo(label: $0.name, icon: $0.sfSymbol, color: $0.color) },
            onSelectPredefined: { cat in
                useCustomCategory = false
                selectedPredefined = cat
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

    // MARK: - Recurring

    private static let recurrenceOptions: [RecurrenceFrequency] = [.weekly, .monthly, .yearly]

    private var isRecurring: Binding<Bool> {
        Binding(
            get: { recurrenceFrequency != .never },
            set: { recurrenceFrequency = $0 ? .yearly : .never }
        )
    }

    private var recurrenceSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(String(localized: "Repeat", comment: "Date form: toggle label for recurrence"))
                        .font(.bodyDefault)
                        .fontWeight(.medium)
                        .foregroundStyle(Color.textPrimary)

                    Text(String(localized: "Repeats on a schedule", comment: "Date form: subtitle explaining repeat toggle"))
                        .font(.caption)
                        .foregroundStyle(Color.textTertiary)
                }

                Spacer()

                Toggle(isOn: isRecurring) {}
                    .labelsHidden()
                    .tint(Color.accentPrimary)
            }
            .padding(Spacing.lg)
            .background(Color.bgSurface)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.md)
                    .strokeBorder(Color.borderSubtle, lineWidth: 1)
            )

            if recurrenceFrequency != .never {
                VStack(spacing: 0) {
                    ForEach(Array(Self.recurrenceOptions.enumerated()), id: \.element) { index, option in
                        if index > 0 {
                            Rectangle()
                                .fill(Color.borderSubtle)
                                .frame(height: 1)
                                .padding(.horizontal, Spacing.xl)
                        }

                        Button {
                            recurrenceFrequency = option
                        } label: {
                            HStack {
                                Text(option.displayName)
                                    .font(.custom(FontFamily.ui, size: 14, relativeTo: .subheadline))
                                    .fontWeight(.medium)
                                    .foregroundStyle(Color.textPrimary)

                                Spacer()

                                if recurrenceFrequency == option {
                                    Image(systemName: "checkmark")
                                        .font(.custom(FontFamily.ui, size: 13, relativeTo: .footnote).weight(.semibold))
                                        .foregroundStyle(Color.accentPrimary)
                                        .accessibilityHidden(true)
                                }
                            }
                            .padding(.horizontal, Spacing.xl)
                            .padding(.vertical, Spacing.lg)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityAddTraits(recurrenceFrequency == option ? .isSelected : [])
                    }
                }
                .background(Color.bgSurface)
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
                .overlay(
                    RoundedRectangle(cornerRadius: CornerRadius.md)
                        .strokeBorder(Color.borderSubtle, lineWidth: 1)
                )
                .transition(.scale(scale: 0.8, anchor: .top).combined(with: .opacity))
            }
        }
        .animation(.motionAware(.easeInOut(duration: 0.2)), value: recurrenceFrequency)
    }

    // MARK: - Reminder

    private static let reminderOptions: [(label: String, days: Int)] = [
        (String(localized: "On the day", comment: "Reminder option: notify on the date itself"), 0),
        (String(localized: "1 day before", comment: "Reminder option: notify 1 day before"), 1),
        (String(localized: "2 days before", comment: "Reminder option: notify 2 days before"), 2),
        (String(localized: "3 days before", comment: "Reminder option: notify 3 days before"), 3),
        (String(localized: "1 week before", comment: "Reminder option: notify 1 week before"), 7),
        (String(localized: "2 weeks before", comment: "Reminder option: notify 2 weeks before"), 14),
        (String(localized: "1 month before", comment: "Reminder option: notify 1 month before"), 30),
    ]

    private var reminderSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(String(localized: "Reminder", comment: "Date form: toggle label for date reminder"))
                        .font(.bodyDefault)
                        .fontWeight(.medium)
                        .foregroundStyle(Color.textPrimary)

                    Text(String(localized: "Get notified before this date", comment: "Date form: subtitle explaining reminder toggle"))
                        .font(.caption)
                        .foregroundStyle(Color.textTertiary)
                }

                Spacer()

                Toggle(isOn: $reminderEnabled) {}
                    .labelsHidden()
                    .tint(Color.accentPrimary)
            }
            .padding(Spacing.lg)
            .background(Color.bgSurface)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.md)
                    .strokeBorder(Color.borderSubtle, lineWidth: 1)
            )

            if reminderEnabled {
                VStack(spacing: 0) {
                    ForEach(Array(Self.reminderOptions.enumerated()), id: \.element.days) { index, option in
                        if index > 0 {
                            Rectangle()
                                .fill(Color.borderSubtle)
                                .frame(height: 1)
                                .padding(.horizontal, Spacing.xl)
                        }

                        Button {
                            reminderDaysBefore = option.days
                        } label: {
                            HStack {
                                Text(option.label)
                                    .font(.custom(FontFamily.ui, size: 14, relativeTo: .subheadline))
                                    .fontWeight(.medium)
                                    .foregroundStyle(Color.textPrimary)

                                Spacer()

                                if reminderDaysBefore == option.days {
                                    Image(systemName: "checkmark")
                                        .font(.custom(FontFamily.ui, size: 13, relativeTo: .footnote).weight(.semibold))
                                        .foregroundStyle(Color.accentPrimary)
                                        .accessibilityHidden(true)
                                }
                            }
                            .padding(.horizontal, Spacing.xl)
                            .padding(.vertical, Spacing.lg)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityAddTraits(reminderDaysBefore == option.days ? .isSelected : [])
                    }
                }
                .background(Color.bgSurface)
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
                .overlay(
                    RoundedRectangle(cornerRadius: CornerRadius.md)
                        .strokeBorder(Color.borderSubtle, lineWidth: 1)
                )
                .transition(.scale(scale: 0.8, anchor: .top).combined(with: .opacity))
            }
        }
        .animation(.motionAware(.easeInOut(duration: 0.2)), value: reminderEnabled)
    }

    // MARK: - Actions

    private func populateFromExisting() {
        guard let existing = existingDate else { return }
        title = existing.title
        date = existing.date
        note = existing.note ?? ""
        recurrenceFrequency = existing.recurrenceFrequency
        reminderEnabled = existing.reminderEnabled
        reminderDaysBefore = existing.reminderDaysBefore
        if let custom = existing.customCategory {
            useCustomCategory = true
            selectedCustomCategory = custom
        } else {
            selectedPredefined = existing.predefinedCategory
        }
    }

    private func save() {
        ImportantDateService.save(.init(
            existing: existingDate,
            title: title,
            date: date,
            note: note,
            recurrenceFrequency: recurrenceFrequency,
            reminderEnabled: reminderEnabled,
            reminderDaysBefore: reminderDaysBefore,
            useCustomCategory: useCustomCategory,
            selectedPredefined: selectedPredefined,
            selectedCustomCategory: selectedCustomCategory,
            person: person
        ), in: modelContext)
        scheduleNotifications()
        dismiss()
    }

    private func scheduleNotifications() {
        if reminderEnabled {
            Task {
                let granted = await NotificationService.shared.requestPermission()
                if granted {
                    NotificationService.shared.rescheduleAll(modelContext: modelContext)
                }
            }
        } else if let existingDate {
            NotificationService.shared.removeNotification(for: existingDate)
        }
    }
}

#Preview {
    ImportantDateFormSheet(person: .preview, customCategories: [])
        .modelContainer(for: [Person.self, ImportantDate.self, DateCategory.self], inMemory: true)
}
