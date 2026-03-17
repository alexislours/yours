import SwiftData
import SwiftUI

struct SizesGridView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    let person: Person

    @State private var showingAddSheet = false
    @State private var editingItem: ClothingSizeItem?
    @State private var itemToDelete: ClothingSizeItem?
    @Query private var customCategories: [ClothingSizeCategory]

    private var filledItems: [ClothingSizeItem] {
        (person.clothingSizeItems ?? []).sorted {
            $0.categoryDisplayName
                .localizedCaseInsensitiveCompare($1.categoryDisplayName) == .orderedAscending
        }
    }

    private let columns = [
        GridItem(.flexible(), spacing: Spacing.md),
        GridItem(.flexible(), spacing: Spacing.md),
    ]

    var body: some View {
        let items = filledItems
        ListScaffold(isEmpty: items.isEmpty) {
            header(showManageButton: !items.isEmpty)
        } emptyContent: {
            emptyState
        } content: {
            grid(items: items)
        } fab: {
            fab
        }
        .navigationBarBackButtonHidden(true)
        .background(SwipeBackEnabler())
        .sheet(isPresented: $showingAddSheet) {
            ClothingSizeFormSheet(person: person, customCategories: customCategories)
        }
        .sheet(item: $editingItem) { item in
            ClothingSizeFormSheet(person: person, existingItem: item, customCategories: customCategories)
        }
        .deleteConfirmation(
            String(localized: "Delete size?", comment: "Delete confirmation: title for deleting a clothing size"),
            item: $itemToDelete
        ) { item in
            withAnimation {
                modelContext.delete(item)
            }
        }
    }

    // MARK: - Header

    private func header(showManageButton: Bool) -> some View {
        DetailHeader(title: Text(String(localized: "Sizes", comment: "Sizes: screen title")), dismiss: dismiss) {
            if showManageButton {
                NavigationLink(destination: ManageClothingSizeCategoriesView()) {
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
            icon: "ruler",
            iconColor: CategoryPalette.color(for: "sage"),
            title: String(localized: "No sizes yet", comment: "Sizes: empty state title"),
            description: String(localized: "Keep track of their sizes for easy shopping", comment: "Sizes: empty state description"),
            buttonLabel: String(localized: "Add their first size", comment: "Sizes: empty state button"),
            action: { showingAddSheet = true }
        )
    }

    // MARK: - FAB

    private var fab: some View {
        FABButton(accessibilityLabel: "Add size") { showingAddSheet = true }
    }

    // MARK: - Grid

    private func grid(items: [ClothingSizeItem]) -> some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: Spacing.md) {
                ForEach(items) { item in
                    sizeCard(item)
                }
            }
            .padding(.horizontal, Spacing.xxxl)
            .padding(.top, Spacing.lg)
            .padding(.bottom, Spacing.screen)
            .animation(.listReorder, value: items.map(\.id))
        }
    }

    // MARK: - Size Card

    private func sizeCard(_ item: ClothingSizeItem) -> some View {
        Button(action: { editingItem = item }, label: {
            VStack(alignment: .leading, spacing: Spacing.md) {
                IconBadge(
                    systemName: item.categoryIcon,
                    iconColor: item.categoryColor,
                    backgroundColor: item.categoryColor.opacity(Opacity.iconBackground)
                )

                Text(item.categoryDisplayName.uppercased())
                    .font(.sectionLabel)
                    .foregroundStyle(Color.textTertiary)

                Text(item.size)
                    .font(.bodyDefault)
                    .fontWeight(.medium)
                    .foregroundStyle(Color.textPrimary)
                    .lineLimit(1)
            }
            .padding(Spacing.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.bgSurface, in: RoundedRectangle(cornerRadius: CornerRadius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.lg)
                    .strokeBorder(Color.borderSubtle, lineWidth: 1)
            )
        })
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .editDeleteContextMenu(
            onEdit: { editingItem = item },
            onDelete: { itemToDelete = item }
        )
    }
}

#Preview("With items") {
    NavigationStack {
        SizesGridView(person: .preview)
    }
}

#Preview("Empty") {
    NavigationStack {
        SizesGridView(person: .preview)
    }
}
