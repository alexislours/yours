import SwiftData
import SwiftUI

struct FoodOrdersView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    let person: Person

    @State private var searchText = ""
    @State private var showingAddSheet = false
    @State private var editingItem: FoodOrderItem?
    @State private var itemToDelete: FoodOrderItem?
    @State private var showCopiedToast = false
    @Query private var customCategories: [FoodOrderCategory]

    private var allItems: [FoodOrderItem] {
        person.foodOrderItems ?? []
    }

    private var isEmpty: Bool {
        allItems.isEmpty
    }

    private var filteredItems: [FoodOrderItem] {
        guard !searchText.isEmpty else { return allItems }
        return allItems.filter {
            $0.place.localizedCaseInsensitiveContains(searchText)
                || $0.order.localizedCaseInsensitiveContains(searchText)
                || ($0.note?.localizedCaseInsensitiveContains(searchText) ?? false)
        }
    }

    private struct FoodOrderCategoryGroup: Identifiable {
        let group: CategoryGroup<FoodOrderItem>
        let displayOrder: Int

        var id: String {
            group.id
        }
    }

    private var groupedItems: [FoodOrderCategoryGroup] {
        var groups: [String: [FoodOrderItem]] = [:]

        for item in filteredItems {
            groups[item.categoryGroupKey, default: []].append(item)
        }

        return groups.map { key, items in
            let sorted = items.sorted { $0.sortOrder < $1.sortOrder }
            let first = sorted[0]

            let order: Int = if let predefined = FoodOrderPredefinedCategory(rawValue: key) {
                predefined.displayOrder
            } else {
                100
            }

            return FoodOrderCategoryGroup(
                group: CategoryGroup(
                    key: key, name: first.categoryDisplayName,
                    icon: first.categoryIcon, color: first.categoryColor,
                    items: sorted
                ),
                displayOrder: order
            )
        }
        .sorted { $0.displayOrder < $1.displayOrder }
    }

    var body: some View {
        ListScaffold(isEmpty: isEmpty) {
            header
        } emptyContent: {
            emptyState
        } content: {
            itemsList
        } fab: {
            fab
        }
        .navigationBarBackButtonHidden(true)
        .background(SwipeBackEnabler())
        .sheet(isPresented: $showingAddSheet) {
            FoodOrderFormSheet(person: person, customCategories: customCategories)
        }
        .sheet(item: $editingItem) { item in
            FoodOrderFormSheet(person: person, existingItem: item, customCategories: customCategories)
        }
        .deleteConfirmation(
            String(localized: "Delete order?", comment: "Delete confirmation: title for deleting a food order"),
            item: $itemToDelete
        ) { item in
            withAnimation {
                modelContext.delete(item)
            }
        }
        .toast(
            String(localized: "Copied to clipboard", comment: "Food orders: toast after copying an order to clipboard"),
            isPresented: $showCopiedToast,
            duration: 1.5
        )
    }

    // MARK: - Header

    private var header: some View {
        DetailHeader(title: Text(String(localized: "Food & drink orders", comment: "Food orders: screen title")), dismiss: dismiss) {
            if !isEmpty {
                NavigationLink(destination: ManageFoodOrderCategoriesView()) {
                    Image(systemName: "tag")
                        .font(.custom(FontFamily.ui, size: 16, relativeTo: .callout).weight(.medium))
                        .foregroundStyle(Color.textSecondary)
                }
                .accessibilityLabel(String(localized: "Manage categories", comment: "Accessibility: manage categories button"))
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        EmptyStateView(
            icon: "menucard.fill",
            iconColor: CategoryPalette.color(for: "eucalyptus"),
            title: String(localized: "No orders saved", comment: "Food orders: empty state title"),
            // swiftlint:disable:next line_length
            description: String(localized: "Their go-to orders, all in one place. You're at the counter, they're not with you. Open the app, read the order, done.", comment: "Food orders: empty state description"),
            buttonLabel: String(localized: "Add an order", comment: "Food orders: empty state button"),
            action: { showingAddSheet = true }
        )
    }

    // MARK: - FAB

    private var fab: some View {
        FABButton(accessibilityLabel: "Add order") { showingAddSheet = true }
    }

    // MARK: - Items List

    private var itemsList: some View {
        List {
            searchBar
                .plainListRow(top: Spacing.xxxl, bottom: Spacing.sm)

            ForEach(groupedItems) { entry in
                Section {
                    ForEach(entry.group.items) { item in
                        itemRow(item)
                    }
                    .onMove { indices, destination in
                        moveItems(entry.group.items, from: indices, to: destination)
                    }
                } header: {
                    CategorySectionHeader(icon: entry.group.icon, color: entry.group.color, name: entry.group.name)
                }
                .plainListRow()
            }

            if filteredItems.isEmpty, !allItems.isEmpty {
                noResultsView
                    .plainListRow(top: Spacing.block, bottom: 0)
            }

            ListBottomSpacer()
        }
        .appListStyle(animatingBy: filteredItems.map(\.id))
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        SearchBar(placeholder: String(localized: "Search orders", comment: "Food orders: search bar placeholder"), text: $searchText)
    }

    // MARK: - Item Row

    private func itemRow(_ item: FoodOrderItem) -> some View {
        CategorizedItemRow(
            name: item.place,
            subtitle: item.order,
            note: item.note,
            onTap: { editingItem = item },
            trailing: { EmptyView() }
        )
        .contextMenu {
            Button(action: { copyOrder(item) }, label: {
                Label(String(localized: "Copy order", comment: "Context menu: copy a food order to clipboard"), systemImage: "doc.on.doc")
            })
            Button(action: { editingItem = item }, label: {
                Label(String(localized: "Edit", comment: "Context menu: edit action"), systemImage: "pencil")
            })
            Button(role: .destructive, action: { itemToDelete = item }, label: {
                Label(String(localized: "Delete", comment: "Context menu: delete action"), systemImage: "trash")
            })
        }
        .editDeleteSwipeActions(
            onEdit: { editingItem = item },
            onDelete: { itemToDelete = item }
        )
        .swipeActions(edge: .leading, allowsFullSwipe: true) {
            Button(action: { copyOrder(item) }, label: {
                Label(String(localized: "Copy", comment: "Swipe action: copy to clipboard"), systemImage: "doc.on.doc")
                    .labelStyle(.iconOnly)
            })
            .tint(CategoryPalette.color(for: "eucalyptus"))
        }
    }

    // MARK: - Copy

    private func copyOrder(_ item: FoodOrderItem) {
        UIPasteboard.general.string = item.order
        HapticFeedback.fire(.success)
        withAnimation { showCopiedToast = true }
    }

    // MARK: - No Results

    private var noResultsView: some View {
        NoResultsView(
            icon: "menucard",
            message: String(localized: "No orders match your search", comment: "Food orders: shown when search returns no results")
        )
    }

    // MARK: - Reorder

    private func moveItems(_ items: [FoodOrderItem], from source: IndexSet, to destination: Int) {
        var mutable = items
        mutable.move(fromOffsets: source, toOffset: destination)
        for (index, item) in mutable.enumerated() {
            item.sortOrder = index
        }
    }
}

#Preview("With items") {
    NavigationStack {
        FoodOrdersView(person: .preview)
    }
}

#Preview("Empty") {
    NavigationStack {
        FoodOrdersView(person: .preview)
    }
}
