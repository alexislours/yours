import SwiftData
import SwiftUI

struct GiftIdeasView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    let person: Person
    var startWithNewIdea: Bool = false

    @State private var searchText = ""
    @State private var selectedFilter: String?
    @State private var showingAddSheet = false
    @State private var editingIdea: GiftIdea?
    @State private var ideaToDelete: GiftIdea?
    @State private var selectedIdea: GiftIdea?
    @Query private var customCategories: [GiftCategory]

    private var allIdeas: [GiftIdea] {
        person.giftIdeas ?? []
    }

    private var filteredIdeas: [GiftIdea] {
        var result = allIdeas

        if selectedFilter != GiftStatus.archived.rawValue {
            result = result.filter { $0.status != .archived }
        }

        if !searchText.isEmpty {
            result = result.filter {
                $0.title.localizedCaseInsensitiveContains(searchText)
                    || ($0.note?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }

        if let filter = selectedFilter {
            result = result.filter { $0.status.rawValue == filter }
        }

        return result.sorted { $0.createdAt > $1.createdAt }
    }

    private var isEmpty: Bool {
        allIdeas.isEmpty
    }

    var body: some View {
        ListScaffold(isEmpty: isEmpty) {
            header
        } emptyContent: {
            emptyState
        } content: {
            ideasList
        } fab: {
            fab
        }
        .navigationBarBackButtonHidden(true)
        .background(SwipeBackEnabler())
        .navigationDestination(item: $selectedIdea) { idea in
            GiftIdeaDetailView(idea: idea)
        }
        .sheet(isPresented: $showingAddSheet) {
            GiftIdeaFormSheet(person: person, customCategories: customCategories)
        }
        .sheet(item: $editingIdea) { idea in
            GiftIdeaFormSheet(person: person, existingIdea: idea, customCategories: customCategories)
        }
        .onAppear {
            if startWithNewIdea {
                showingAddSheet = true
            }
        }
        .deleteConfirmation(
            String(localized: "Delete idea?", comment: "Delete confirmation: title for deleting a gift idea"),
            item: $ideaToDelete
        ) { idea in
            withAnimation {
                modelContext.delete(idea)
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        DetailHeader(title: Text(String(localized: "Gift ideas", comment: "Gift ideas: screen title")), dismiss: dismiss) {
            if !isEmpty {
                NavigationLink(destination: ManageGiftCategoriesView()) {
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
            icon: "lightbulb",
            iconColor: Color.accentRose,
            title: String(localized: "No ideas saved", comment: "Gift ideas: empty state title"),
            // swiftlint:disable line_length
            description: person.gendered(
                female: String(localized: "When inspiration strikes, save it here. You'll thank yourself when her birthday comes around.", comment: "Gift ideas: empty state, female"),
                male: String(localized: "When inspiration strikes, save it here. You'll thank yourself when his birthday comes around.", comment: "Gift ideas: empty state, male"),
                other: String(localized: "When inspiration strikes, save it here. You'll thank yourself when their birthday comes around.", comment: "Gift ideas: empty state, non-binary")
            ),
            // swiftlint:enable line_length
            buttonLabel: String(localized: "Add an idea", comment: "Gift ideas: empty state button"),
            action: { showingAddSheet = true }
        )
    }

    // MARK: - FAB

    private var fab: some View {
        FABButton(accessibilityLabel: "Add gift idea") { showingAddSheet = true }
    }

    // MARK: - Ideas List

    private var ideasList: some View {
        List {
            searchBar
                .plainListRow(top: Spacing.xxxl, bottom: Spacing.sm)

            filterChips
                .plainListRow(bottom: Spacing.sm)

            if !filteredIdeas.isEmpty {
                ForEach(filteredIdeas) { idea in
                    ideaRow(idea)
                }
                .plainListRow()
            }

            if filteredIdeas.isEmpty, !allIdeas.isEmpty {
                noResultsView
                    .plainListRow(top: Spacing.block, bottom: 0)
            }

            ListBottomSpacer()
        }
        .appListStyle(animatingBy: filteredIdeas.map(\.id))
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        SearchBar(placeholder: String(localized: "Search ideas", comment: "Gift ideas: search bar placeholder"), text: $searchText)
    }

    // MARK: - Filter Chips

    private var statusFilters: [(id: String, label: String)] {
        [
            (GiftStatus.idea.rawValue, String(localized: "Idea", comment: "Gift status filter: idea stage")),
            (GiftStatus.purchased.rawValue, String(localized: "Purchased", comment: "Gift status filter: purchased stage")),
            (GiftStatus.given.rawValue, String(localized: "Given", comment: "Gift status filter: given stage")),
            (GiftStatus.archived.rawValue, String(localized: "Archived", comment: "Gift status filter: archived stage")),
        ]
    }

    private var filterChips: some View {
        FilterChipBar(options: statusFilters, selectedFilter: $selectedFilter)
    }

    // MARK: - Idea Row

    private func ideaRow(_ idea: GiftIdea) -> some View {
        Button(action: { selectedIdea = idea }, label: {
            HStack(spacing: Spacing.lg) {
                IconBadge(
                    systemName: idea.categoryIcon,
                    iconColor: idea.categoryColor,
                    backgroundColor: idea.categoryColor.opacity(Opacity.iconBackground),
                    size: 32
                )

                VStack(alignment: .leading, spacing: 2) {
                    Text(idea.title)
                        .font(.bodyDefault)
                        .fontWeight(.medium)
                        .foregroundStyle(Color.textPrimary)
                        .lineLimit(1)

                    HStack(spacing: Spacing.xs) {
                        Text(idea.status.displayName)
                            .font(.caption)
                            .foregroundStyle(idea.status.color)

                        if let price = idea.formattedPrice {
                            Text(verbatim: "·")
                                .font(.caption)
                                .foregroundStyle(Color.textTertiary)
                                .accessibilityHidden(true)
                            Text(price)
                                .font(.caption)
                                .foregroundStyle(Color.textTertiary)
                        }
                    }
                }

                Spacer()

                if let domain = idea.domainName {
                    Text(domain)
                        .font(.sectionLabel)
                        .fontWeight(.medium)
                        .foregroundStyle(Color.accentPrimary)
                        .padding(.horizontal, Spacing.sm)
                        .padding(.vertical, 3)
                        .background(Color.accentPrimarySoft, in: Capsule())
                        .lineLimit(1)
                }
            }
            .cardStyle()
        })
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .contextMenu {
            Button(action: { editingIdea = idea }, label: {
                Label(String(localized: "Edit", comment: "Context menu: edit action"), systemImage: "pencil")
            })

            if let next = idea.status.next {
                Button(action: { advanceStatus(idea, to: next) }, label: {
                    Label(
                        String(localized: "Mark as \(next.displayName)",
                               comment: "Context menu: change gift status, e.g. 'Mark as purchased'"),
                        systemImage: next.icon
                    )
                })
            }

            if idea.status != .archived {
                Button(action: { advanceStatus(idea, to: .archived) }, label: {
                    Label(String(localized: "Archive", comment: "Context menu: archive a gift idea"), systemImage: "archivebox")
                })
            }

            Button(role: .destructive, action: { ideaToDelete = idea }, label: {
                Label(String(localized: "Delete", comment: "Context menu: delete action"), systemImage: "trash")
            })
        }
        .editDeleteSwipeActions(
            onEdit: { editingIdea = idea },
            onDelete: { ideaToDelete = idea }
        )
        .swipeActions(edge: .leading, allowsFullSwipe: true) {
            if let next = idea.status.next {
                Button(action: { advanceStatus(idea, to: next) }, label: {
                    Label(next.displayName, systemImage: next.icon)
                        .labelStyle(.iconOnly)
                })
                .tint(next.color)
            }
        }
    }

    private func advanceStatus(_ idea: GiftIdea, to status: GiftStatus) {
        withAnimation {
            idea.status = status
            idea.updatedAt = .now
        }
    }

    // MARK: - No Results

    private var noResultsView: some View {
        NoResultsView(
            icon: "gift",
            message: String(localized: "No gifts for current selection", comment: "Gift ideas: shown when filter returns no results")
        )
    }
}

#Preview {
    GiftIdeasView(person: .preview)
        .modelContainer(for: [Person.self, GiftIdea.self, GiftCategory.self, ImportantDate.self, DateCategory.self], inMemory: true)
}
