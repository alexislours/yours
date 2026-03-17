import SwiftData
import SwiftUI

struct AskAboutView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    let person: Person
    var startFocused: Bool = false

    @State private var newItemTitle = ""
    @State private var showDatePicker = false
    @State private var newItemDueDate: Date?
    @State private var pickerDate = Date()
    @State private var searchText = ""
    @State private var doneExpanded = false
    @State private var editingItem: AskAboutItem?
    @State private var editingTitle = ""
    @State private var showClearAllConfirmation = false
    @State private var itemDateEditing: AskAboutItem?
    @State private var itemDatePickerDate = Date()
    @FocusState private var isAddFieldFocused: Bool
    @State private var showAddField = false
    @FocusState private var isEditFieldFocused: Bool

    private var allItems: [AskAboutItem] {
        person.askAboutItems ?? []
    }

    private var activeItems: [AskAboutItem] {
        let items = allItems.filter { !$0.isDone }
        let filtered = searchText.isEmpty ? items : items.filter {
            $0.title.localizedCaseInsensitiveContains(searchText)
        }
        return filtered.sorted { $0.createdAt > $1.createdAt }
    }

    private var doneItems: [AskAboutItem] {
        let items = allItems.filter(\.isDone)
        let filtered = searchText.isEmpty ? items : items.filter {
            $0.title.localizedCaseInsensitiveContains(searchText)
        }
        return filtered.sorted { $0.createdAt > $1.createdAt }
    }

    private var isEmpty: Bool {
        allItems.isEmpty
    }

    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(.horizontal, Spacing.xxxl)

            if isEmpty, !showAddField {
                Spacer()
                emptyState
                    .padding(.horizontal, Spacing.xxxl)
                Spacer()
            } else {
                itemsList
                    .transition(.opacity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.bgPrimary)
        .navigationBarBackButtonHidden(true)
        .background(SwipeBackEnabler())
        .animation(.emptyState, value: isEmpty && !showAddField)
        .onAppear {
            if startFocused {
                showAddField = true
                Task {
                    try? await Task.sleep(for: .focusDelay)
                    isAddFieldFocused = true
                }
            }
        }
        .deleteConfirmation(
            String(localized: "Clear all done items?", comment: "Delete confirmation: title for clearing all completed items"),
            isPresented: $showClearAllConfirmation,
            buttonLabel: String(localized: "Clear all", comment: "Delete confirmation: button to clear all completed items")
        ) {
            clearAllDone()
        }
        .sheet(item: $itemDateEditing) { item in
            AskAboutItemDatePickerSheet(
                item: item,
                pickerDate: $itemDatePickerDate,
                itemDateEditing: $itemDateEditing
            )
        }
    }

    // MARK: - Header

    private var askAboutTitle: Text {
        let fullString = String(
            localized: "Ask \(person.firstName) about",
            comment: "Ask about: screen title with person's name - translators can reorder"
        )
        var attributed = AttributedString(fullString)
        if let range = attributed.range(of: person.firstName) {
            attributed[range].foregroundColor = Color.accentPrimary
        }
        return Text(attributed)
    }

    private var header: some View {
        DetailHeader(
            title: askAboutTitle,
            dismiss: dismiss
        )
    }

    // MARK: - Empty State

    private var emptyState: some View {
        EmptyStateView(
            icon: "bubble.left.and.text.bubble.right",
            iconColor: Color(.caution),
            title: String(localized: "Nothing to ask yet", comment: "Ask about: empty state title"),
            // swiftlint:disable:next line_length
            description: String(localized: "Did \(person.firstName) mention a job interview, a doctor's visit, or something they were excited about? Add it here so you remember to follow up.", comment: "Ask about: empty state description with person's name"),
            buttonLabel: String(localized: "Add a question", comment: "Ask about: empty state button"),
            buttonColor: Color.accentPrimary
        ) {
            withAnimation(.emptyState) {
                showAddField = true
            }
            Task {
                try? await Task.sleep(for: .focusDelay)
                isAddFieldFocused = true
            }
        }
    }

    // MARK: - Items List

    private var itemsList: some View {
        let active = activeItems
        let done = doneItems

        return List {
            searchBar
                .plainListRow(top: Spacing.xxxl, bottom: Spacing.sm)

            AskAboutAddField(
                newItemTitle: $newItemTitle,
                showDatePicker: $showDatePicker,
                newItemDueDate: $newItemDueDate,
                pickerDate: $pickerDate,
                isAddFieldFocused: $isAddFieldFocused,
                onAdd: addItem
            )
            .plainListRow(bottom: Spacing.sm)

            ForEach(active) { item in
                if editingItem?.id == item.id {
                    AskAboutEditField(
                        editingTitle: $editingTitle,
                        isEditFieldFocused: $isEditFieldFocused,
                        onSave: { saveEdit(item) },
                        onCancel: cancelEditing
                    )
                    .plainListRow()
                    .transition(.opacity)
                } else {
                    AskAboutItemRow(
                        item: item,
                        onToggleDone: { toggleDone(item) },
                        onStartEditing: { startEditing(item) },
                        onDelete: { deleteItem(item) },
                        onEditDate: {
                            itemDatePickerDate = item.dueDate ?? Date()
                            itemDateEditing = item
                        }
                    )
                    .plainListRow()
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            deleteItem(item)
                        } label: {
                            Label(String(localized: "Delete", comment: "Swipe action: delete item"), systemImage: "trash")
                                .labelStyle(.iconOnly)
                        }
                        .tint(Color.error)
                    }
                    .swipeActions(edge: .leading, allowsFullSwipe: true) {
                        Button {
                            startEditing(item)
                        } label: {
                            Label(String(localized: "Edit", comment: "Swipe action: edit item"), systemImage: "pencil")
                                .labelStyle(.iconOnly)
                        }
                        .tint(Color.accentSecondary)
                    }
                }
            }

            if !searchText.isEmpty, active.isEmpty, done.isEmpty {
                noResultsView
                    .plainListRow(top: Spacing.block, bottom: 0)
            }

            if !done.isEmpty {
                doneSection(done: done)
            }

            ListBottomSpacer()
        }
        .appListStyle(animatingBy: active.map(\.id))
        .animation(.listReorder, value: done.map(\.id))
        .animation(.expandCollapse, value: doneExpanded)
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        SearchBar(placeholder: String(localized: "Search", comment: "Generic search bar placeholder"), text: $searchText)
    }

    // MARK: - Done Section

    private func doneSection(done: [AskAboutItem]) -> some View {
        Section {
            if doneExpanded {
                ForEach(done) { item in
                    AskAboutItemRow(
                        item: item,
                        onToggleDone: { toggleDone(item) },
                        onStartEditing: { startEditing(item) },
                        onDelete: { deleteItem(item) },
                        onEditDate: {
                            itemDatePickerDate = item.dueDate ?? Date()
                            itemDateEditing = item
                        }
                    )
                    .plainListRow()
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            deleteItem(item)
                        } label: {
                            Label(String(localized: "Delete", comment: "Swipe action: delete item"), systemImage: "trash")
                                .labelStyle(.iconOnly)
                        }
                        .tint(Color.error)
                    }
                }
            }
        } header: {
            Button {
                HapticFeedback.impact(.light)
                withAnimation(.expandCollapse) {
                    doneExpanded.toggle()
                }
            } label: {
                HStack {
                    Image(systemName: "chevron.right")
                        .font(.custom(FontFamily.ui, size: 12, relativeTo: .caption).weight(.semibold))
                        .foregroundStyle(Color.textTertiary)
                        .rotationEffect(.degrees(doneExpanded ? 90 : 0))
                        .accessibilityHidden(true)

                    Text(String(localized: "Done", comment: "Ask about: section header for completed items"))
                        .font(.sectionLabel)
                        .foregroundStyle(Color.textTertiary)
                        .textCase(nil)

                    Text(verbatim: "\(done.count)")
                        .font(.caption)
                        .foregroundStyle(Color.textTertiary)

                    Spacer()

                    if doneExpanded {
                        Button(String(localized: "Clear all", comment: "Ask about: button to delete all completed items")) {
                            showClearAllConfirmation = true
                        }
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(Color.textSecondary)
                        .buttonStyle(.plain)
                        .transition(.opacity)
                    }
                }
            }
            .buttonStyle(.plain)
            .plainListRow(top: Spacing.lg)
        }
    }

    // MARK: - No Results

    private var noResultsView: some View {
        NoResultsView(
            title: String(localized: "No items found", comment: "Ask about: shown when search returns no results"),
            subtitle: String(localized: "Try a different search term.", comment: "No results: suggestion to refine search")
        )
    }

    // MARK: - Actions

    private func addItem() {
        guard let trimmed = newItemTitle.nonBlank else { return }
        let item = AskAboutItem(title: trimmed, person: person, dueDate: newItemDueDate)
        modelContext.insert(item)
        newItemTitle = ""
        newItemDueDate = nil
        showDatePicker = false
    }

    private func toggleDone(_ item: AskAboutItem) {
        HapticFeedback.impact(.light)
        withAnimation(.listReorder) {
            item.isDone.toggle()
            item.updatedAt = .now
        }
    }

    private func deleteItem(_ item: AskAboutItem) {
        withAnimation {
            modelContext.delete(item)
        }
    }

    private func startEditing(_ item: AskAboutItem) {
        editingTitle = item.title
        editingItem = item
        Task {
            try? await Task.sleep(for: .focusDelay)
            isEditFieldFocused = true
        }
    }

    private func cancelEditing() {
        isEditFieldFocused = false
        editingItem = nil
        editingTitle = ""
    }

    private func saveEdit(_ item: AskAboutItem) {
        guard let trimmed = editingTitle.nonBlank else { return }
        item.title = trimmed
        item.updatedAt = .now
        isEditFieldFocused = false
        editingItem = nil
        editingTitle = ""
    }

    private func clearAllDone() {
        let done = allItems.filter(\.isDone)
        withAnimation {
            for item in done {
                modelContext.delete(item)
            }
        }
    }
}

#Preview {
    AskAboutView(person: .preview)
        .modelContainer(for: Person.self, inMemory: true)
}
