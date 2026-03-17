import SwiftData
import SwiftUI

struct TheirPeopleListView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    let person: Person

    @State private var showingAddSheet = false
    @State private var editingItem: TheirPeopleItem?
    @State private var itemToDelete: TheirPeopleItem?
    @Query private var customCategories: [TheirPeopleCategory]

    private var allItems: [TheirPeopleItem] {
        person.theirPeopleItems ?? []
    }

    private var isEmpty: Bool {
        allItems.isEmpty
    }

    private var groupedItems: [CategoryGroup<TheirPeopleItem>] {
        var groups: [String: [TheirPeopleItem]] = [:]

        for item in allItems {
            groups[item.categoryGroupKey, default: []].append(item)
        }

        return groups.map { key, items in
            if key == "family" {
                let sorted = items.sorted { lhs, rhs in
                    if lhs.familySortOrder != rhs.familySortOrder {
                        return lhs.familySortOrder < rhs.familySortOrder
                    }
                    return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
                }
                let familyColor = CategoryPalette.color(for: TheirPeoplePredefinedCategory.familyColorName)
                return CategoryGroup(
                    key: key, name: "Family",
                    icon: TheirPeoplePredefinedCategory.familyIcon,
                    color: familyColor, items: sorted
                )
            }
            let sorted = items.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
            let first = sorted[0]
            return CategoryGroup(
                key: key, name: first.categoryDisplayName,
                icon: first.categoryIcon, color: first.categoryColor,
                items: sorted
            )
        }
        .sorted { lhs, rhs in
            let lhsOrder = lhs.items[0].categoryDisplayOrder
            let rhsOrder = rhs.items[0].categoryDisplayOrder
            switch (lhsOrder, rhsOrder) {
            case let (.some(lhsVal), .some(rhsVal)):
                return lhsVal < rhsVal
            case (.some, .none):
                return true
            case (.none, .some):
                return false
            case (.none, .none):
                return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
            }
        }
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
            TheirPeopleFormSheet(person: person, customCategories: customCategories)
        }
        .sheet(item: $editingItem) { item in
            TheirPeopleFormSheet(person: person, existingItem: item, customCategories: customCategories)
        }
        .deleteConfirmation(
            String(localized: "Delete person?", comment: "Delete confirmation: title for deleting a person"),
            item: $itemToDelete
        ) { item in
            withAnimation {
                modelContext.delete(item)
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        DetailHeader(title: Text(String(localized: "Their People", comment: "Their people: screen title")), dismiss: dismiss) {
            if !isEmpty {
                NavigationLink(destination: ManageTheirPeopleCategoriesView()) {
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
            icon: "person.2.fill",
            iconColor: CategoryPalette.color(for: "lavender"),
            title: String(localized: "No people yet", comment: "Their people: empty state title"),
            // swiftlint:disable:next line_length
            description: String(localized: "The people who matter to them. Family, friends, coworkers, anyone worth remembering by name.", comment: "Their people: empty state description"),
            buttonLabel: String(localized: "Add a person", comment: "Their people: empty state button"),
            action: { showingAddSheet = true }
        )
    }

    // MARK: - FAB

    private var fab: some View {
        FABButton(accessibilityLabel: "Add person") { showingAddSheet = true }
    }

    // MARK: - Items List

    private var itemsList: some View {
        List {
            ForEach(groupedItems, id: \.key) { group in
                Section {
                    ForEach(group.items) { item in
                        itemRow(item)
                    }
                } header: {
                    CategorySectionHeader(icon: group.icon, color: group.color, name: group.name)
                }
                .plainListRow()
            }

            ListBottomSpacer()
        }
        .appListStyle(animatingBy: allItems.map(\.id))
    }

    // MARK: - Item Row

    private func itemRow(_ item: TheirPeopleItem) -> some View {
        CategorizedItemRow(
            name: item.name,
            subtitle: nil,
            note: item.note,
            onTap: { editingItem = item },
            trailing: {
                if let tag = item.relationshipTag {
                    Text(tag)
                        .font(.sectionLabel)
                        .fontWeight(.medium)
                        .foregroundStyle(item.categoryColor)
                        .padding(.horizontal, Spacing.sm)
                        .padding(.vertical, 3)
                        .background(item.categoryColor.opacity(Opacity.iconBackground), in: Capsule())
                }
            }
        )
        .editDeleteContextMenu(
            onEdit: { editingItem = item },
            onDelete: { itemToDelete = item }
        )
        .editDeleteSwipeActions(
            onEdit: { editingItem = item },
            onDelete: { itemToDelete = item }
        )
    }
}

#Preview("With items") {
    NavigationStack {
        TheirPeopleListView(person: .preview)
    }
}

#Preview("Empty") {
    NavigationStack {
        TheirPeopleListView(person: .preview)
    }
}
