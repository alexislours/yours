import SwiftUI

struct SearchResultsOverlay: View {
    @Binding var searchText: String
    let person: Person
    let onSelect: (HomeView.HomeDestination) -> Void

    @State private var searchResults: [SearchResultGroup] = []

    var body: some View {
        Group {
            if searchText.isEmpty {
                searchPrompt
            } else {
                searchContent
            }
        }
        .task(id: searchText) {
            guard !searchText.isEmpty else {
                searchResults = []
                return
            }
            try? await Task.sleep(for: .milliseconds(150))
            guard !Task.isCancelled else { return }
            searchResults = GlobalSearchService.search(query: searchText, person: person)
        }
    }

    private var searchContent: some View {
        ScrollView {
            if searchResults.isEmpty {
                NoResultsView(
                    icon: "magnifyingglass",
                    message: String(
                        localized: "No results",
                        comment: "Search: empty results message"
                    )
                )
                .padding(.top, Spacing.block)
            } else {
                resultsList
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .animation(.emptyState, value: searchResults.map(\.id))
    }

    // MARK: - Prompt

    private var searchPrompt: some View {
        VStack(spacing: Spacing.sm) {
            Image(systemName: "magnifyingglass")
                .font(.custom(FontFamily.ui, size: 28, relativeTo: .title).weight(.light))
                .foregroundStyle(Color.textTertiary)
            Text(String(
                localized: "Search notes, gifts, dates, and more",
                comment: "Search: prompt when search is empty"
            ))
            .font(.bodySmall)
            .foregroundStyle(Color.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Results

    private var resultsList: some View {
        VStack(spacing: Spacing.xxl) {
            ForEach(searchResults) { group in
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    sectionHeader(group: group)
                    ForEach(group.results) { result in
                        resultRow(result: result)
                    }
                }
            }
        }
        .padding(.horizontal, Spacing.xxxl)
        .padding(.bottom, Spacing.block)
    }

    private func sectionHeader(group: SearchResultGroup) -> some View {
        HStack(spacing: Spacing.sm) {
            IconBadge(
                systemName: group.sectionIcon,
                iconColor: group.sectionIconColor,
                backgroundColor: group.sectionIconBackground,
                size: 28
            )
            Text(group.sectionTitle)
                .font(.custom(FontFamily.ui, size: 14, relativeTo: .subheadline))
                .fontWeight(.semibold)
                .foregroundStyle(Color.textSecondary)
        }
        .padding(.horizontal, Spacing.xxs)
    }

    private func resultRow(result: SearchResult) -> some View {
        Button { onSelect(result.destination) } label: {
            HStack(spacing: Spacing.lg) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(result.title)
                        .font(.bodyDefault)
                        .fontWeight(.medium)
                        .foregroundStyle(Color.textPrimary)
                        .lineLimit(1)
                    if let subtitle = result.subtitle, !subtitle.isEmpty {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundStyle(Color.textSecondary)
                            .lineLimit(1)
                    }
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.custom(FontFamily.ui, size: 12, relativeTo: .caption).weight(.medium))
                    .foregroundStyle(Color.textTertiary)
            }
            .cardStyle()
        }
        .buttonStyle(.plain)
    }
}
