import SwiftUI

// MARK: - AskAboutAddField

struct AskAboutAddField: View {
    @Binding var newItemTitle: String
    @Binding var showDatePicker: Bool
    @Binding var newItemDueDate: Date?
    @Binding var pickerDate: Date
    var isAddFieldFocused: FocusState<Bool>.Binding
    var onAdd: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: Spacing.md) {
                Image(systemName: "plus.circle")
                    .font(.custom(FontFamily.ui, size: 20, relativeTo: .title3))
                    .foregroundStyle(Color.textTertiary)

                TextField(
                    String(localized: "Add something to ask about", comment: "Ask about: placeholder for new item input"),
                    text: $newItemTitle
                )
                .font(.custom(FontFamily.ui, size: 14, relativeTo: .subheadline))
                .foregroundStyle(Color.textPrimary)
                .focused(isAddFieldFocused)
                .onSubmit { onAdd() }

                if newItemTitle.nonBlank != nil {
                    HStack(spacing: Spacing.sm) {
                        Button {
                            withAnimation(.expandCollapse) {
                                showDatePicker.toggle()
                            }
                        } label: {
                            Image(systemName: newItemDueDate != nil ? "calendar.badge.checkmark" : "calendar")
                                .font(.custom(FontFamily.ui, size: 15, relativeTo: .callout))
                                .foregroundStyle(newItemDueDate != nil ? Color.accentPrimary : Color.textTertiary)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(Text("Set due date", comment: "Ask about: calendar toggle accessibility label"))

                        Button(action: onAdd) {
                            Text(String(localized: "Add", comment: "Ask about: button to add a new question item"))
                                .font(.bodySmall)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color.accentPrimary)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.md)

            if showDatePicker {
                Divider()
                    .padding(.horizontal, Spacing.lg)

                HStack {
                    DatePicker(
                        String(localized: "Due date", comment: "Ask about: label for the due date picker"),
                        selection: $pickerDate,
                        in: Date()...,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.compact)
                    .font(.bodySmall)
                    .labelsHidden()

                    Spacer()

                    if newItemDueDate != nil {
                        Button(String(localized: "Remove", comment: "Due date picker: button to remove a due date")) {
                            newItemDueDate = nil
                            withAnimation(.expandCollapse) {
                                showDatePicker = false
                            }
                        }
                        .font(.bodySmall)
                        .foregroundStyle(Color.textSecondary)
                        .buttonStyle(.plain)
                    }

                    Button(String(localized: "Set", comment: "Due date picker: button to confirm a due date")) {
                        newItemDueDate = pickerDate
                        withAnimation(.expandCollapse) {
                            showDatePicker = false
                        }
                    }
                    .font(.bodySmall)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.accentPrimary)
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.vertical, Spacing.sm)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(Color.bgSurface)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: CornerRadius.lg)
                .strokeBorder(Color.borderSubtle, lineWidth: 1)
        )
    }
}

// MARK: - AskAboutItemRow

struct AskAboutItemRow: View {
    let item: AskAboutItem
    var onToggleDone: () -> Void
    var onStartEditing: () -> Void
    var onDelete: () -> Void
    var onEditDate: () -> Void

    var body: some View {
        HStack(spacing: Spacing.md) {
            Button {
                onToggleDone()
            } label: {
                Image(systemName: item.isDone ? "checkmark.circle.fill" : "circle")
                    .font(.custom(FontFamily.ui, size: 22, relativeTo: .title2))
                    .foregroundStyle(item.isDone ? Color.positive : Color.textTertiary)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text(item.title)
                    .font(.custom(FontFamily.ui, size: 14, relativeTo: .subheadline))
                    .foregroundStyle(item.isDone ? Color.textTertiary : Color.textPrimary)
                    .strikethrough(item.isDone)
                    .lineSpacing(3)

                if let dateText = item.formattedDueDate {
                    Text(dateText)
                        .font(.caption)
                        .foregroundStyle(item.isOverdue ? Color.error : Color.textTertiary)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .animation(.expandCollapse, value: item.dueDate)

            if !item.isDone {
                Button {
                    onEditDate()
                } label: {
                    Image(systemName: item.dueDate != nil ? "calendar.badge.checkmark" : "calendar")
                        .font(.custom(FontFamily.ui, size: 15, relativeTo: .callout))
                        .foregroundStyle(item.dueDate != nil ? Color.accentPrimary : Color.textTertiary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.md)
        .background(Color.bgSurface)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: CornerRadius.lg)
                .strokeBorder(Color.borderSubtle, lineWidth: 1)
        )
        .contextMenu {
            Button(action: onStartEditing) {
                Label(String(localized: "Edit", comment: "Context menu: edit action"), systemImage: "pencil")
            }
            Button(action: onEditDate) {
                Label(
                    item.dueDate != nil
                        ? String(localized: "Change due date", comment: "Context menu: change an existing due date")
                        : String(localized: "Set due date", comment: "Context menu: set a new due date"),
                    systemImage: "calendar"
                )
            }
            Button(role: .destructive, action: onDelete) {
                Label(String(localized: "Delete", comment: "Context menu: delete action"), systemImage: "trash")
            }
        }
    }
}

// MARK: - AskAboutEditField

struct AskAboutEditField: View {
    @Binding var editingTitle: String
    var isEditFieldFocused: FocusState<Bool>.Binding
    var onSave: () -> Void
    var onCancel: () -> Void

    var body: some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: "circle")
                .font(.custom(FontFamily.ui, size: 22, relativeTo: .title2))
                .foregroundStyle(Color.textTertiary)

            TextField(text: $editingTitle) {}
                .font(.custom(FontFamily.ui, size: 14, relativeTo: .subheadline))
                .foregroundStyle(Color.textPrimary)
                .focused(isEditFieldFocused)
                .onSubmit { onSave() }

            HStack(spacing: Spacing.sm) {
                Button(action: onCancel) {
                    Text(String(localized: "Cancel", comment: "Generic cancel button"))
                        .font(.bodySmall)
                        .fontWeight(.medium)
                        .foregroundStyle(Color.textSecondary)
                }
                .buttonStyle(.plain)

                Button(action: onSave) {
                    Text(String(localized: "Save", comment: "Generic save button"))
                        .font(.bodySmall)
                        .fontWeight(.semibold)
                        .foregroundStyle(
                            editingTitle.nonBlank == nil
                                ? Color.textTertiary
                                : Color.accentPrimary
                        )
                }
                .buttonStyle(.plain)
                .disabled(editingTitle.nonBlank == nil)
            }
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.md)
        .background(Color.bgSurface)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: CornerRadius.lg)
                .strokeBorder(Color(.caution).opacity(0.5), lineWidth: 1)
        )
    }
}

// MARK: - AskAboutItemDatePickerSheet

struct AskAboutItemDatePickerSheet: View {
    let item: AskAboutItem
    @Binding var pickerDate: Date
    @Binding var itemDateEditing: AskAboutItem?

    var body: some View {
        VStack(spacing: Spacing.block) {
            Capsule()
                .fill(Color.borderSubtle)
                .frame(width: 36, height: 5)
                .padding(.top, Spacing.md)

            Text(String(localized: "Due Date", comment: "Ask about: date picker sheet title"))
                .font(.heading1)
                .foregroundStyle(Color.textPrimary)
                .tracking(-0.3)

            DatePicker(
                selection: $pickerDate,
                in: Date()...,
                displayedComponents: .date
            ) {}
                .datePickerStyle(.graphical)
                .tint(Color.accentPrimary)
                .padding(Spacing.sm)
                .background(Color.bgSurface, in: RoundedRectangle(cornerRadius: CornerRadius.xl))
                .overlay(
                    RoundedRectangle(cornerRadius: CornerRadius.xl)
                        .strokeBorder(Color.borderSubtle, lineWidth: 1)
                )

            Spacer()

            VStack(spacing: Spacing.lg) {
                Button {
                    item.dueDate = pickerDate
                    item.updatedAt = .now
                    itemDateEditing = nil
                } label: {
                    Text(String(localized: "Save", comment: "Generic save button"))
                        .font(.label)
                        .foregroundStyle(Color.textOnAccent)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Spacing.lg)
                        .background(Color.accentPrimary, in: Capsule())
                }

                if item.dueDate != nil {
                    Button(role: .destructive) {
                        item.dueDate = nil
                        item.updatedAt = .now
                        itemDateEditing = nil
                    } label: {
                        Text(String(localized: "Remove due date", comment: "Ask about: destructive button to remove a due date"))
                            .font(.bodySmall)
                            .foregroundStyle(Color.error)
                    }
                }
            }
        }
        .padding(.horizontal, Spacing.xxxl)
        .padding(.bottom, Spacing.xxxl)
        .background(Color.bgPrimary)
        .presentationDetents([.large])
    }
}
