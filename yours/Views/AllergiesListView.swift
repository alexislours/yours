import SwiftData
import SwiftUI

struct AllergiesListView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    let person: Person

    @State private var showingAddSheet = false
    @State private var editingItem: AllergyItem?
    @State private var itemToDelete: AllergyItem?
    @Query private var customCategories: [AllergyCategory]
    @AppStorage(UserDefaultsKeys.hiddenAllergyCategories) private var hiddenCategoriesRaw: String = ""

    private var allItems: [AllergyItem] {
        person.allergyItems ?? []
    }

    private var isEmpty: Bool {
        allItems.isEmpty
    }

    private var groupedItems: [CategoryGroup<AllergyItem>] {
        CategoryGroup.grouped(from: allItems, sortedBy: \.name)
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
            AllergyFormSheet(person: person, customCategories: customCategories, hiddenCategoriesRaw: hiddenCategoriesRaw)
        }
        .sheet(item: $editingItem) { item in
            AllergyFormSheet(
                person: person, existingItem: item,
                customCategories: customCategories,
                hiddenCategoriesRaw: hiddenCategoriesRaw
            )
        }
        .deleteConfirmation(
            String(localized: "Delete allergy?", comment: "Delete confirmation: title for deleting an allergy"),
            item: $itemToDelete
        ) { item in
            withAnimation {
                modelContext.delete(item)
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        DetailHeader(title: Text(String(localized: "Allergies", comment: "Allergies: screen title")), dismiss: dismiss) {
            if !isEmpty {
                NavigationLink(destination: ManageAllergyCategoriesView()) {
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
            icon: "cross.case.fill",
            iconColor: CategoryPalette.color(for: "amber"),
            title: String(localized: "No allergies yet", comment: "Allergies: empty state title"),
            // swiftlint:disable:next line_length
            description: String(localized: "The things to watch out for. Food allergies, dietary needs, the details that keep them safe and comfortable.", comment: "Allergies: empty state description"),
            buttonLabel: String(localized: "Add an allergy", comment: "Allergies: empty state button"),
            action: { showingAddSheet = true }
        )
    }

    // MARK: - FAB

    private var fab: some View {
        FABButton(accessibilityLabel: "Add allergy") { showingAddSheet = true }
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

    private func itemRow(_ item: AllergyItem) -> some View {
        CategorizedItemRow(
            name: item.name,
            subtitle: nil,
            note: item.note,
            onTap: { editingItem = item },
            trailing: { EmptyView() }
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
        AllergiesListView(person: .preview)
    }
}

#Preview("Empty") {
    NavigationStack {
        AllergiesListView(person: .preview)
    }
}
