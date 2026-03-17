import SwiftData
import SwiftUI

struct LikesDislikesListView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    let person: Person
    let kind: Kind

    @State private var showingAddSheet = false
    @State private var editingItem: LikeDislikeItem?
    @State private var itemToDelete: LikeDislikeItem?
    @Query private var customCategories: [LikeDislikeCategory]
    @AppStorage(UserDefaultsKeys.hiddenLikeDislikeCategories) private var hiddenCategoriesRaw: String = ""

    enum Kind {
        case likes, dislikes

        var title: String {
            switch self {
            case .likes: "Likes"
            case .dislikes: "Dislikes"
            }
        }

        var icon: String {
            switch self {
            case .likes: "heart.fill"
            case .dislikes: "heart.slash"
            }
        }

        var iconColor: Color {
            switch self {
            case .likes: .accentSecondary
            case .dislikes: .accentRose
            }
        }

        var emptyTitle: String {
            switch self {
            case .likes: String(localized: "No likes yet", comment: "Likes: empty state title")
            case .dislikes: String(localized: "No dislikes yet", comment: "Dislikes: empty state title")
            }
        }

        var emptyDescription: String {
            switch self {
            case .likes:
                String(
                    localized: "What makes them light up? Favorite foods, hobbies, little pleasures -- keep track of it all.",
                    comment: "Likes: empty state description"
                )
            case .dislikes:
                String(
                    localized: "The things they'd rather avoid. Knowing what they don't like matters just as much.",
                    comment: "Dislikes: empty state description"
                )
            }
        }

        var addLabel: String {
            switch self {
            case .likes: String(localized: "Add a like", comment: "Likes: empty state button to add a like")
            case .dislikes: String(localized: "Add a dislike", comment: "Dislikes: empty state button to add a dislike")
            }
        }

        var fabAccessibilityLabel: LocalizedStringResource {
            switch self {
            case .likes: "Add like"
            case .dislikes: "Add dislike"
            }
        }

        var placeholder: String {
            switch self {
            case .likes: String(localized: "Something they love...", comment: "Likes: text field placeholder")
            case .dislikes: String(localized: "Something they dislike...", comment: "Dislikes: text field placeholder")
            }
        }

        var itemKind: LikeDislikeItem.Kind {
            switch self {
            case .likes: .like
            case .dislikes: .dislike
            }
        }
    }

    private var allItems: [LikeDislikeItem] {
        switch kind {
        case .likes: person.likes
        case .dislikes: person.dislikes
        }
    }

    private var isEmpty: Bool {
        allItems.isEmpty
    }

    private var groupedItems: [CategoryGroup<LikeDislikeItem>] {
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
            LikeDislikeFormSheet(person: person, kind: kind, customCategories: customCategories, hiddenCategoriesRaw: hiddenCategoriesRaw)
        }
        .sheet(item: $editingItem) { item in
            LikeDislikeFormSheet(
                person: person, kind: kind, existingItem: item,
                customCategories: customCategories,
                hiddenCategoriesRaw: hiddenCategoriesRaw
            )
        }
        .deleteConfirmation(
            kind == .likes
                ? String(localized: "Delete like?", comment: "Delete confirmation: title for deleting a like")
                : String(localized: "Delete dislike?", comment: "Delete confirmation: title for deleting a dislike"),
            item: $itemToDelete
        ) { item in
            withAnimation {
                modelContext.delete(item)
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        DetailHeader(title: Text(kind.title), dismiss: dismiss) {
            if !isEmpty {
                NavigationLink(destination: ManageLikeDislikeCategoriesView()) {
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
            icon: kind.icon,
            iconColor: kind.iconColor,
            title: kind.emptyTitle,
            description: kind.emptyDescription,
            buttonLabel: kind.addLabel,
            action: { showingAddSheet = true }
        )
    }

    // MARK: - FAB

    private var fab: some View {
        FABButton(accessibilityLabel: kind.fabAccessibilityLabel) { showingAddSheet = true }
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

    private func itemRow(_ item: LikeDislikeItem) -> some View {
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

#Preview("Likes with items") {
    NavigationStack {
        LikesDislikesListView(person: .preview, kind: .likes)
    }
}

#Preview("Dislikes empty") {
    NavigationStack {
        LikesDislikesListView(person: .preview, kind: .dislikes)
    }
}
