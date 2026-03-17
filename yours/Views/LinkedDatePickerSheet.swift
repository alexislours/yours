import SwiftData
import SwiftUI

struct LinkedDatePickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    let dates: [ImportantDate]
    @Binding var selection: ImportantDate?

    @State private var searchText = ""

    private var upcomingDates: [ImportantDate] {
        dates.filter { !$0.isPast }
    }

    private var filteredDates: [ImportantDate] {
        let base = upcomingDates
        if searchText.isEmpty { return base }
        return base.filter {
            $0.title.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                DetailHeader(title: Text(String(localized: "Link a date", comment: "Linked date picker: sheet title")), dismiss: dismiss)
                    .padding(.horizontal, Spacing.xxxl)

                List {
                    searchBar
                        .plainListRow(top: Spacing.xxxl, bottom: Spacing.sm)

                    if selection != nil {
                        Button {
                            selection = nil
                            dismiss()
                        } label: {
                            HStack(spacing: Spacing.lg) {
                                IconBadge(
                                    systemName: "xmark.circle",
                                    iconColor: Color.error,
                                    backgroundColor: Color.error.opacity(Opacity.iconBackground),
                                    size: 32
                                )

                                Text(String(localized: "Unlink date", comment: "Linked date picker: button to remove date link"))
                                    .font(.bodyDefault)
                                    .fontWeight(.medium)
                                    .foregroundStyle(Color.error)
                            }
                            .padding(Spacing.lg)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.bgSurface)
                            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.lg))
                            .overlay(
                                RoundedRectangle(cornerRadius: CornerRadius.lg)
                                    .strokeBorder(Color.borderSubtle, lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                        .plainListRow()
                    }

                    ForEach(filteredDates) { date in
                        Button {
                            selection = date
                            dismiss()
                        } label: {
                            dateRow(date)
                        }
                        .buttonStyle(.plain)
                        .accessibilityAddTraits(selection?.id == date.id ? .isSelected : [])
                        .plainListRow()
                    }

                    if filteredDates.isEmpty, !searchText.isEmpty {
                        VStack(spacing: Spacing.sm) {
                            Text(String(localized: "No dates found", comment: "Linked date picker: empty search result title"))
                                .font(.heading3)
                                .foregroundStyle(Color.textPrimary)
                            Text(String(localized: "Try a different search", comment: "Linked date picker: empty search result suggestion"))
                                .font(.bodySmall)
                                .foregroundStyle(Color.textSecondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, Spacing.block)
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    }

                    ListBottomSpacer()
                }
                .appListStyle()
            }
            .background(Color.bgPrimary)
            .navigationBarBackButtonHidden(true)
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        SearchBar(placeholder: String(localized: "Search dates", comment: "Linked date picker: search bar placeholder"), text: $searchText)
    }

    // MARK: - Date Row

    private func dateRow(_ date: ImportantDate) -> some View {
        HStack(spacing: Spacing.lg) {
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

            if selection?.id == date.id {
                Image(systemName: "checkmark")
                    .font(.custom(FontFamily.ui, size: 13, relativeTo: .footnote).weight(.semibold))
                    .foregroundStyle(Color.accentPrimary)
                    .accessibilityHidden(true)
            }
        }
        .padding(Spacing.lg)
        .background(Color.bgSurface)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: CornerRadius.lg)
                .strokeBorder(
                    selection?.id == date.id ? Color.accentPrimary : Color.borderSubtle,
                    lineWidth: 1
                )
        )
    }
}
