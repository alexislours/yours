import SwiftData
import SwiftUI

struct InlineEditableListView<Item: PersistentModel, Card: View>: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    let person: Person

    // Configuration
    let title: String
    let itemsKeyPath: KeyPath<Person, [Item]?>
    let textKeyPath: ReferenceWritableKeyPath<Item, String>
    let sortKeyPath: KeyPath<Item, Date>
    let searchPlaceholder: String
    let noResultsLabel: String
    let deleteConfirmationMessage: String
    let emptyStateIcon: String
    let emptyStateTitle: String
    let emptyStateDescription: String
    let emptyStateButtonLabel: String
    let editorPlaceholder: String
    let editorLineLimit: ClosedRange<Int>
    let editorMaxLength: Int?
    let editorWarningThreshold: Int?
    let sortable: Bool
    let fabAccessibilityLabel: LocalizedStringResource
    let makeItem: (String, Person) -> Item
    let onSaveEdit: ((Item) -> Void)?
    @ViewBuilder let cardContent: (Item) -> Card
    var startWithNew: Bool = false

    // State
    @State private var isCreating = false
    @State private var editingItem: Item?
    @State private var draftText = ""
    @State private var searchText = ""
    @State private var sortNewestFirst = true
    @State private var showChrome = true
    @State private var firstItemCenter = false
    @State private var itemToDelete: Item?
    @FocusState private var isTextFocused: Bool

    private var allItems: [Item] {
        person[keyPath: itemsKeyPath] ?? []
    }

    private var filteredItems: [Item] {
        let filtered: [Item] = if searchText.isEmpty {
            allItems
        } else {
            allItems.filter {
                $0[keyPath: textKeyPath].localizedCaseInsensitiveContains(searchText)
            }
        }
        return filtered.sorted {
            sortNewestFirst
                ? $0[keyPath: sortKeyPath] > $1[keyPath: sortKeyPath]
                : $0[keyPath: sortKeyPath] < $1[keyPath: sortKeyPath]
        }
    }

    private var isEmpty: Bool {
        allItems.isEmpty
    }

    private var trimmedDraft: String? {
        draftText.nonBlank
    }

    private var remaining: Int? {
        guard let maxLength = editorMaxLength else { return nil }
        return maxLength - draftText.count
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 0) {
                header
                    .padding(.horizontal, Spacing.xxxl)

                if isEmpty, !isCreating {
                    Spacer()
                    emptyState
                        .padding(.horizontal, Spacing.xxxl)
                    Spacer()
                } else if firstItemCenter {
                    Spacer()
                    if isCreating {
                        editor(text: $draftText, onSave: saveNew, onCancel: cancelCreating)
                            .padding(.horizontal, Spacing.xxxl)
                            .transition(.scale(scale: 0.95).combined(with: .opacity))
                    } else if let item = filteredItems.first {
                        cardContent(item)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .cardStyle(padding: Spacing.xl)
                            .padding(.horizontal, Spacing.xxxl)
                            .transition(.scale(scale: 0.95).combined(with: .opacity))
                    }
                    Spacer()
                } else {
                    itemsList
                        .transition(.opacity)
                }
            }
            .animation(.emptyState, value: isEmpty)
            .animation(.motionAware(.spring(response: 0.5, dampingFraction: 0.85)), value: firstItemCenter)

            if !isEmpty, !isCreating, editingItem == nil, showChrome {
                FABButton(accessibilityLabel: fabAccessibilityLabel, action: startCreating)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.bgPrimary)
        .navigationBarBackButtonHidden(true)
        .background(SwipeBackEnabler())
        .onAppear {
            if startWithNew {
                startCreating()
            }
        }
        .deleteConfirmation(deleteConfirmationMessage, item: $itemToDelete) { item in
            let willBeEmpty = allItems.count <= 1
            if willBeEmpty { showChrome = false }
            withAnimation {
                modelContext.delete(item)
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        DetailHeader(title: Text(title), dismiss: dismiss) {
            if sortable, !isEmpty, showChrome {
                Button(action: { withAnimation(.expandCollapse) { sortNewestFirst.toggle() } }, label: {
                    Image(systemName: "arrow.down")
                        .font(.custom(FontFamily.ui, size: 16, relativeTo: .callout).weight(.medium))
                        .foregroundStyle(Color.textSecondary)
                        .rotationEffect(.degrees(sortNewestFirst ? 0 : 180))
                })
                .accessibilityLabel(
                    sortNewestFirst
                        ? String(localized: "Sort oldest first", comment: "Accessibility: sort button, currently newest first")
                        : String(localized: "Sort newest first", comment: "Accessibility: sort button, currently oldest first")
                )
                .transition(.opacity)
            } else {
                EmptyView()
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        EmptyStateView(
            icon: emptyStateIcon,
            iconColor: Color(.caution),
            title: emptyStateTitle,
            description: emptyStateDescription,
            buttonLabel: emptyStateButtonLabel,
            buttonColor: Color.accentPrimary,
            action: startCreating
        )
    }

    // MARK: - List

    private var itemsList: some View {
        List {
            if !isEmpty, showChrome {
                SearchBar(placeholder: searchPlaceholder, text: $searchText)
                    .plainListRow(top: Spacing.xxxl, bottom: Spacing.sm)
            }

            if isCreating {
                editor(text: $draftText, onSave: saveNew, onCancel: cancelCreating)
                    .plainListRow()
                    .transition(.scale(scale: 0.95).combined(with: .opacity))
            }

            ForEach(filteredItems) { item in
                if editingItem?.id == item.id {
                    editor(
                        text: Binding(
                            get: { draftText },
                            set: { draftText = $0 }
                        ),
                        onSave: { saveEdit(item) },
                        onCancel: cancelEditing
                    )
                    .plainListRow()
                    .transition(.opacity)
                } else {
                    cardContent(item)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .editDeleteContextMenu(
                            onEdit: { startEditing(item) },
                            onDelete: { itemToDelete = item }
                        )
                        .padding(Spacing.xl)
                        .cardListRow()
                        .editDeleteSwipeActions(
                            onEdit: { startEditing(item) },
                            onDelete: { itemToDelete = item }
                        )
                }
            }

            if !searchText.isEmpty, filteredItems.isEmpty {
                NoResultsView(
                    title: noResultsLabel,
                    subtitle: String(localized: "Try a different search term.", comment: "No results: suggestion to refine search")
                )
                .plainListRow(top: Spacing.block, bottom: 0)
            }

            ListBottomSpacer()
        }
        .appListStyle(animatingBy: filteredItems.map(\.id))
        .animation(.listReorder, value: isCreating)
        .animation(.listReorder, value: editingItem?.id)
    }

    // MARK: - Editor

    private func editor(
        text: Binding<String>,
        onSave: @escaping () -> Void,
        onCancel: @escaping () -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            TextField(editorPlaceholder, text: text, axis: .vertical)
                .font(.custom(FontFamily.ui, size: 14, relativeTo: .subheadline))
                .foregroundStyle(Color.textPrimary)
                .lineSpacing(3)
                .lineLimit(editorLineLimit)
                .focused($isTextFocused)
                .onChange(of: text.wrappedValue) { _, newValue in
                    if let maxLength = editorMaxLength, newValue.count > maxLength {
                        text.wrappedValue = String(newValue.prefix(maxLength))
                    }
                }

            HStack {
                Button(action: onCancel) {
                    Text(String(localized: "Cancel", comment: "Generic cancel button"))
                        .font(.bodySmall)
                        .fontWeight(.medium)
                        .foregroundStyle(Color.textSecondary)
                }
                .buttonStyle(.plain)

                Spacer()

                if let remaining, let threshold = editorWarningThreshold, remaining <= threshold {
                    Text(verbatim: "\(remaining)")
                        .font(.caption)
                        .foregroundStyle(remaining <= 0 ? Color.error : Color.textTertiary)
                        .monospacedDigit()
                }

                Button(action: onSave) {
                    Text(String(localized: "Save", comment: "Generic save button"))
                        .font(.bodySmall)
                        .fontWeight(.semibold)
                        .foregroundStyle(trimmedDraft == nil ? Color.textTertiary : Color.accentPrimary)
                }
                .buttonStyle(.plain)
                .disabled(trimmedDraft == nil)
            }
        }
        .padding(Spacing.xl)
        .background(Color.bgSurface)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: CornerRadius.lg)
                .strokeBorder(Color(.caution).opacity(0.5), lineWidth: 1)
        )
    }

    // MARK: - Actions

    private func startCreating() {
        draftText = ""
        let isFirst = isEmpty
        if isFirst { showChrome = false }
        withAnimation(.emptyState) {
            isCreating = true
            if isFirst { firstItemCenter = true }
        }
        Task {
            try? await Task.sleep(for: .focusDelay)
            isTextFocused = true
        }
    }

    private func cancelCreating() {
        isTextFocused = false
        withAnimation(.emptyState) {
            isCreating = false
            if firstItemCenter {
                firstItemCenter = false
            }
        }
        draftText = ""
    }

    private func saveNew() {
        guard let trimmed = trimmedDraft else { return }
        let wasFirst = firstItemCenter
        let item = makeItem(trimmed, person)
        modelContext.insert(item)
        isTextFocused = false
        withOptionalAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
            isCreating = false
            if wasFirst {
                firstItemCenter = false
                showChrome = true
            }
        }
        draftText = ""
    }

    private func startEditing(_ item: Item) {
        draftText = item[keyPath: textKeyPath]
        editingItem = item
        Task {
            try? await Task.sleep(for: .focusDelay)
            isTextFocused = true
        }
    }

    private func cancelEditing() {
        isTextFocused = false
        editingItem = nil
        draftText = ""
    }

    private func saveEdit(_ item: Item) {
        guard let trimmed = trimmedDraft else { return }
        item[keyPath: textKeyPath] = trimmed
        onSaveEdit?(item)
        isTextFocused = false
        editingItem = nil
        draftText = ""
    }
}
