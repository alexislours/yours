import SwiftData
import SwiftUI

struct ImportantDatesView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    let person: Person

    @State private var searchText = ""
    @State private var selectedFilter: String?
    @State private var showingAddSheet = false
    @State private var editingDate: ImportantDate?
    @State private var dateToDelete: ImportantDate?
    @State private var selectedDate: ImportantDate?
    @Query private var customCategories: [DateCategory]

    private var allDates: [ImportantDate] {
        person.importantDates ?? []
    }

    private var filteredDates: [ImportantDate] {
        var result = allDates

        if !searchText.isEmpty {
            result = result.filter {
                $0.title.localizedCaseInsensitiveContains(searchText)
            }
        }

        if let filter = selectedFilter {
            if filter == "custom" {
                result = result.filter { $0.customCategory != nil }
            } else {
                result = result.filter { $0.predefinedCategory.rawValue == filter && $0.customCategory == nil }
            }
        }

        return result
    }

    private var isEmpty: Bool {
        allDates.isEmpty
    }

    private var filterOptions: [(id: String, label: String)] {
        let dateCategories = Set(allDates.compactMap { date -> String? in
            if date.customCategory != nil { return "custom" }
            return date.predefinedCategory.rawValue
        })

        var options: [(id: String, label: String)] = ImportantDatePredefinedCategory.allCases
            .filter { $0 != .other && dateCategories.contains($0.rawValue) }
            .map { ($0.rawValue, $0.displayName) }

        if dateCategories.contains("custom") {
            options.append(("custom", String(localized: "Custom", comment: "Date filter: custom category filter chip")))
        }

        return options
    }

    var body: some View {
        ListScaffold(isEmpty: isEmpty) {
            header
        } emptyContent: {
            emptyState
        } content: {
            datesList
        } fab: {
            fab
        }
        .navigationBarBackButtonHidden(true)
        .background(SwipeBackEnabler())
        .navigationDestination(item: $selectedDate) { date in
            ImportantDateDetailView(date: date)
        }
        .sheet(isPresented: $showingAddSheet) {
            ImportantDateFormSheet(person: person, customCategories: customCategories)
        }
        .sheet(item: $editingDate) { date in
            ImportantDateFormSheet(person: person, existingDate: date, customCategories: customCategories)
        }
        .deleteConfirmation(
            String(localized: "Delete date?", comment: "Delete confirmation: title for deleting a date"),
            item: $dateToDelete
        ) { date in
            withAnimation {
                modelContext.delete(date)
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        DetailHeader(title: Text(String(localized: "Important dates", comment: "Important dates: screen title")), dismiss: dismiss) {
            if !isEmpty {
                NavigationLink(destination: ManageCategoriesView()) {
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
            icon: "calendar.badge.plus",
            iconColor: Color.accentPrimary,
            title: String(localized: "No dates yet", comment: "Important dates: empty state title"),
            // swiftlint:disable:next line_length
            description: String(localized: "Birthdays, anniversaries, and the little dates that matter. Add them here so you never forget.", comment: "Important dates: empty state description"),
            buttonLabel: String(localized: "Add a date", comment: "Important dates: empty state button"),
            action: { showingAddSheet = true }
        )
    }

    // MARK: - FAB

    private var fab: some View {
        FABButton(accessibilityLabel: "Add date") { showingAddSheet = true }
            .accessibilityIdentifier("fab-add-date")
    }

    // MARK: - Dates List

    private var datesList: some View {
        let filtered = filteredDates
        let options = filterOptions
        let upcoming = filtered
            .filter { !$0.isPast }
            .sorted { $0.daysUntilNext < $1.daysUntilNext }
        let past = filtered
            .filter(\.isPast)
            .sorted { $0.date > $1.date }

        return List {
            searchBar
                .plainListRow(top: Spacing.xxxl, bottom: Spacing.sm)

            if options.count > 1 {
                FilterChipBar(options: options, selectedFilter: $selectedFilter)
                    .plainListRow(bottom: Spacing.sm)
            }

            if !upcoming.isEmpty {
                Section {
                    ForEach(upcoming) { date in
                        dateRow(date)
                    }
                } header: {
                    Text(String(localized: "Upcoming", comment: "Important dates: section header for future dates"))
                        .font(.sectionLabel)
                        .foregroundStyle(Color.textTertiary)
                        .textCase(nil)
                }
                .plainListRow()
            }

            if !past.isEmpty {
                Section {
                    ForEach(past) { date in
                        dateRow(date)
                    }
                } header: {
                    Text(String(localized: "Past", comment: "Important dates: section header for dates that have passed"))
                        .font(.sectionLabel)
                        .foregroundStyle(Color.textTertiary)
                        .textCase(nil)
                }
                .plainListRow()
            }

            if filtered.isEmpty, !allDates.isEmpty {
                noResultsView
                    .plainListRow(top: Spacing.block, bottom: 0)
            }

            ListBottomSpacer()
        }
        .appListStyle(animatingBy: filtered.map(\.id))
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        SearchBar(placeholder: String(localized: "Search dates", comment: "Important dates: search bar placeholder"), text: $searchText)
    }

    // MARK: - Date Row

    private func dateRow(_ date: ImportantDate) -> some View {
        Button(action: { selectedDate = date }, label: {
            HStack(spacing: Spacing.lg) {
                // Category icon
                IconBadge(
                    systemName: date.categoryIcon,
                    iconColor: date.categoryColor,
                    backgroundColor: date.categoryColor.opacity(Opacity.iconBackground),
                    size: 32
                )

                VStack(alignment: .leading, spacing: 2) {
                    Text(date.title)
                        .font(.bodyDefault)
                        .fontWeight(.medium)
                        .foregroundStyle(Color.textPrimary)
                        .lineLimit(1)

                    Text(date.formattedDate)
                        .font(.caption)
                        .foregroundStyle(Color.textTertiary)
                }

                Spacer()

                if !date.isPast {
                    Text(date.countdownText)
                        .font(.bodySmall)
                        .fontWeight(.medium)
                        .foregroundStyle(date.daysUntilNext <= 7 ? Color.accentPrimary : Color.textTertiary)
                } else if let daysSince = date.daysSinceText {
                    Text(daysSince)
                        .font(.bodySmall)
                        .fontWeight(.medium)
                        .foregroundStyle(Color.textTertiary)
                }

                if date.isRecurring {
                    Image(systemName: "arrow.trianglehead.2.clockwise")
                        .font(.custom(FontFamily.ui, size: 11, relativeTo: .caption2))
                        .foregroundStyle(Color.textTertiary)
                        .accessibilityLabel(String(localized: "Recurring", comment: "Accessibility: indicates date repeats annually"))
                }
            }
            .cardStyle()
        })
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .editDeleteContextMenu(
            onEdit: { editingDate = date },
            onDelete: { dateToDelete = date }
        )
        .editDeleteSwipeActions(
            onEdit: { editingDate = date },
            onDelete: { dateToDelete = date }
        )
    }

    // MARK: - No Results

    private var noResultsView: some View {
        NoResultsView(
            title: String(localized: "No dates found", comment: "Important dates: shown when search returns no results"),
            subtitle: String(localized: "Try a different search or filter.", comment: "No results: suggestion to refine search or filter")
        )
    }
}

#Preview {
    ImportantDatesView(person: .preview)
        .modelContainer(for: [Person.self, ImportantDate.self, DateCategory.self], inMemory: true)
}
