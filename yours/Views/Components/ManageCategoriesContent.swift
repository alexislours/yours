import SwiftData
import SwiftUI

struct ManageCategoriesConfig<C: ManageableCategory & PersistentModel> {
    let headerTitle: String
    let countLabel: (Int) -> String
    let deleteMessage: String
    let placeholderText: String
    let onDeleteReassign: (C) -> Void
    let hiddenCategoriesKey: String?

    init(
        headerTitle: String = String(localized: "Categories", comment: "Manage categories: default section header"),
        countLabel: @escaping (Int) -> String,
        deleteMessage: String,
        placeholderText: String,
        onDeleteReassign: @escaping (C) -> Void,
        hiddenCategoriesKey: String? = nil
    ) {
        self.headerTitle = headerTitle
        self.countLabel = countLabel
        self.deleteMessage = deleteMessage
        self.placeholderText = placeholderText
        self.onDeleteReassign = onDeleteReassign
        self.hiddenCategoriesKey = hiddenCategoriesKey
    }
}

struct ManageCategoriesContent<C: ManageableCategory & PersistentModel, P: PredefinedCategoryType>: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let categories: [C]
    let config: ManageCategoriesConfig<C>

    @AppStorage private var hiddenCategoriesRaw: String

    @State private var showingAddSheet = false
    @State private var editingCategory: C?
    @State private var categoryToDelete: C?

    init(categories: [C], config: ManageCategoriesConfig<C>) {
        self.categories = categories
        self.config = config
        _hiddenCategoriesRaw = AppStorage(
            wrappedValue: "",
            config.hiddenCategoriesKey ?? "_unused_hidden_categories_key"
        )
    }

    private var hiddenCategories: Set<String> {
        Set(hiddenCategoriesRaw.split(separator: ",").map(String.init))
    }

    private func toggleHidden(_ category: P) {
        var set = hiddenCategories
        if set.contains(category.rawValue) {
            set.remove(category.rawValue)
        } else {
            set.insert(category.rawValue)
        }
        hiddenCategoriesRaw = set.sorted().joined(separator: ",")
    }

    private func isHidden(_ category: P) -> Bool {
        hiddenCategories.contains(category.rawValue)
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 0) {
                header
                    .padding(.horizontal, Spacing.xxxl)

                categoriesList
            }

            fab
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.bgPrimary)
        .navigationBarBackButtonHidden(true)
        .background(SwipeBackEnabler())
        .presentationDragIndicator(.visible)
        .sheet(isPresented: $showingAddSheet) {
            CategoryFormSheetContent<C>(placeholderText: config.placeholderText)
        }
        .sheet(item: $editingCategory) { category in
            CategoryFormSheetContent<C>(
                existingCategory: category,
                placeholderText: config.placeholderText
            )
        }
        .deleteConfirmation(
            String(localized: "Delete category?", comment: "Delete confirmation: title for deleting a custom category"),
            item: $categoryToDelete,
            message: config.deleteMessage
        ) { category in
            config.onDeleteReassign(category)
            withAnimation {
                modelContext.delete(category)
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        DetailHeader(title: Text(config.headerTitle), dismiss: dismiss)
    }

    // MARK: - FAB

    private var fab: some View {
        FABButton(accessibilityLabel: "Add category") { showingAddSheet = true }
    }

    // MARK: - List

    private var categoriesList: some View {
        List {
            Section {
                ForEach(Array(P.allCases), id: \.rawValue) { cat in
                    predefinedCategoryRow(cat)
                }
            } header: {
                Text(String(localized: "Built-in", comment: "Manage categories: section header for predefined categories"))
                    .font(.sectionLabel)
                    .foregroundStyle(Color.textTertiary)
                    .textCase(nil)
            }
            .plainListRow()

            if !categories.isEmpty {
                Section {
                    ForEach(categories) { category in
                        Button(action: { editingCategory = category }, label: {
                            categoryRow(
                                icon: category.sfSymbol,
                                color: category.color,
                                name: category.name,
                                trailing: {
                                    let count = category.itemCount
                                    if count > 0 {
                                        CountBadge(text: config.countLabel(count))
                                    }
                                }
                            )
                        })
                        .buttonStyle(.plain)
                        .editDeleteContextMenu(
                            onEdit: { editingCategory = category },
                            onDelete: { categoryToDelete = category }
                        )
                        .editDeleteSwipeActions(
                            onEdit: { editingCategory = category },
                            onDelete: { categoryToDelete = category }
                        )
                    }
                } header: {
                    Text(String(localized: "Custom", comment: "Manage categories: section header for user-created categories"))
                        .font(.sectionLabel)
                        .foregroundStyle(Color.textTertiary)
                        .textCase(nil)
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: Spacing.xs, leading: Spacing.xxxl, bottom: Spacing.xs, trailing: Spacing.xxxl))
            }

            ListBottomSpacer()
        }
        .appListStyle(animatingBy: categories.map(\.id))
    }

    // MARK: - Predefined Category Row

    private func predefinedCategoryRow(_ cat: P) -> some View {
        let hasHideToggle = config.hiddenCategoriesKey != nil && cat.isHideable

        return categoryRow(
            icon: cat.icon,
            color: cat.color,
            name: cat.displayName,
            trailing: {
                HStack(spacing: Spacing.sm) {
                    if hasHideToggle {
                        Button(action: { toggleHidden(cat) }, label: {
                            Image(systemName: isHidden(cat) ? "eye.slash" : "eye")
                                .font(.custom(FontFamily.ui, size: 14, relativeTo: .subheadline))
                                .foregroundStyle(isHidden(cat) ? Color.textTertiary : Color.accentPrimary)
                        })
                        .buttonStyle(.plain)
                        .accessibilityLabel(
                            isHidden(cat)
                                ? String(localized: "Show \(cat.displayName)",
                                         comment: "Accessibility: show hidden category")
                                : String(localized: "Hide \(cat.displayName)",
                                         comment: "Accessibility: hide category")
                        )
                    }

                    CountBadge(text: "Built-in")
                }
            }
        )
        .opacity(hasHideToggle && isHidden(cat) ? 0.5 : 1)
    }

    // MARK: - Category Row

    private func categoryRow(
        icon: String,
        color: Color,
        name: String,
        @ViewBuilder trailing: () -> some View
    ) -> some View {
        HStack(spacing: Spacing.lg) {
            IconBadge(systemName: icon, iconColor: color, backgroundColor: color.opacity(Opacity.iconBackground))

            Text(name)
                .font(.bodyDefault)
                .fontWeight(.medium)
                .foregroundStyle(Color.textPrimary)

            Spacer()

            trailing()
        }
        .cardStyle()
    }
}

// MARK: - Category Form Sheet

struct CategoryFormSheetContent<C: ManageableCategory & PersistentModel>: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    var existingCategory: C?
    let placeholderText: String

    @State private var name = ""
    @State private var selectedSymbol = C.curatedSymbols[0]
    @State private var selectedColor = CategoryPalette.curated[0].name

    private var isEditing: Bool {
        existingCategory != nil
    }

    private var canSave: Bool {
        name.nonBlank != nil
    }

    var body: some View {
        FormSheetWrapper(
            title: Text(isEditing
                ? String(localized: "Edit category", comment: "Category form: sheet title when editing")
                : String(localized: "New category", comment: "Category form: sheet title when creating")),
            canSave: canSave,
            detents: [.large],
            onSave: save
        ) {
            HStack {
                Spacer()
                Image(systemName: selectedSymbol)
                    .font(.custom(FontFamily.ui, size: 28, relativeTo: .title))
                    .foregroundStyle(CategoryPalette.color(for: selectedColor))
                    .frame(width: 56, height: 56)
                    .background(
                        CategoryPalette.color(for: selectedColor).opacity(Opacity.iconBackground),
                        in: RoundedRectangle(cornerRadius: CornerRadius.lg)
                    )
                Spacer()
            }

            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text(String(localized: "Name", comment: "Category form: label for name field"))
                    .font(.sectionLabel)
                    .foregroundStyle(Color.textTertiary)

                TextField(placeholderText, text: $name)
                    .font(.bodyDefault)
                    .foregroundStyle(Color.textPrimary)
                    .padding(.horizontal, Spacing.lg)
                    .padding(.vertical, Spacing.md)
                    .background(Color.bgSurface)
                    .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
                    .overlay(
                        RoundedRectangle(cornerRadius: CornerRadius.md)
                            .strokeBorder(Color.borderSubtle, lineWidth: 1)
                    )
            }

            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text(String(localized: "Symbol", comment: "Category form: label for icon picker"))
                    .font(.sectionLabel)
                    .foregroundStyle(Color.textTertiary)

                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible(), spacing: Spacing.sm), count: 6),
                    spacing: Spacing.sm
                ) {
                    ForEach(C.curatedSymbols, id: \.self) { symbol in
                        Button(action: { selectedSymbol = symbol }, label: {
                            Image(systemName: symbol)
                                .font(.custom(FontFamily.ui, size: 18, relativeTo: .title3))
                                .foregroundStyle(selectedSymbol == symbol ? Color.textOnAccent : Color.textSecondary)
                                .frame(width: 44, height: 44)
                                .background(
                                    selectedSymbol == symbol
                                        ? CategoryPalette.color(for: selectedColor)
                                        : Color.bgSurface,
                                    in: RoundedRectangle(cornerRadius: CornerRadius.md)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: CornerRadius.md)
                                        .strokeBorder(selectedSymbol == symbol ? Color.clear : Color.borderSubtle, lineWidth: 1)
                                )
                        })
                        .buttonStyle(.plain)
                        .accessibilityAddTraits(selectedSymbol == symbol ? .isSelected : [])
                    }
                }
                .hapticFeedback(.selection, trigger: selectedSymbol)
            }

            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text(String(localized: "Color", comment: "Category form: label for color picker"))
                    .font(.sectionLabel)
                    .foregroundStyle(Color.textTertiary)

                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible(), spacing: Spacing.sm), count: 5),
                    spacing: Spacing.sm
                ) {
                    ForEach(CategoryPalette.curated, id: \.name) { colorOption in
                        Button(action: { selectedColor = colorOption.name }, label: {
                            Circle()
                                .fill(CategoryPalette.color(for: colorOption.name))
                                .frame(width: 44, height: 44)
                                .overlay(
                                    Circle()
                                        .strokeBorder(Color.white, lineWidth: selectedColor == colorOption.name ? 3 : 0)
                                )
                                .overlay(
                                    Circle()
                                        .strokeBorder(
                                            CategoryPalette.color(for: colorOption.name).opacity(0.5),
                                            lineWidth: selectedColor == colorOption.name ? 1 : 0
                                        )
                                        .padding(-2)
                                )
                        })
                        .buttonStyle(.plain)
                        .accessibilityLabel(colorOption.name)
                        .accessibilityAddTraits(selectedColor == colorOption.name ? .isSelected : [])
                    }
                }
                .hapticFeedback(.selection, trigger: selectedColor)
            }
        }
        .onAppear {
            if let existing = existingCategory {
                name = existing.name
                selectedSymbol = existing.sfSymbol
                selectedColor = existing.colorName
            }
        }
    }

    private func save() {
        guard let trimmedName = name.nonBlank else { return }

        if let existing = existingCategory {
            existing.name = trimmedName
            existing.sfSymbol = selectedSymbol
            existing.colorName = selectedColor
            existing.updatedAt = .now
        } else {
            let category = C(name: trimmedName, sfSymbol: selectedSymbol, colorName: selectedColor)
            modelContext.insert(category)
        }

        dismiss()
    }
}
