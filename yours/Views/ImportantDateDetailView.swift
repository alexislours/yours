import SwiftData
import SwiftUI

struct ImportantDateDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    let date: ImportantDate
    @Query private var customCategories: [DateCategory]

    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    @State private var selectedGiftIdea: GiftIdea?

    var body: some View {
        VStack(spacing: 0) {
            DetailHeader(title: Text(date.title), dismiss: dismiss) {
                Button(action: { showingEditSheet = true }, label: {
                    Image(systemName: "pencil")
                        .font(.custom(FontFamily.ui, size: 16, relativeTo: .callout).weight(.medium))
                        .foregroundStyle(Color.textSecondary)
                })
            }
            .padding(.horizontal, Spacing.xxxl)

            ScrollView {
                VStack(spacing: Spacing.xxxl) {
                    // MARK: - Hero

                    hero

                    // MARK: - Info rows

                    VStack(spacing: Spacing.md) {
                        InfoRow(
                            icon: "calendar",
                            label: String(localized: "Date", comment: "Important date detail: label for the date field"),
                            value: date.formattedDate
                        )

                        InfoRow(
                            icon: date.categoryIcon,
                            iconColor: date.categoryColor,
                            label: String(localized: "Category", comment: "Important date detail: label for the category field"),
                            value: date.categoryDisplayName
                        )

                        InfoRow(
                            icon: "arrow.trianglehead.2.clockwise",
                            label: String(localized: "Repeats", comment: "Important date detail: label for the recurrence field"),
                            value: date.recurrenceFrequency == .never
                                ? String(localized: "One time", comment: "Important date detail: recurrence value for non-repeating events")
                                : date.recurrenceFrequency.displayName
                        )

                        InfoRow(
                            icon: "bell",
                            iconColor: date.reminderEnabled ? Color.accentPrimary : .textTertiary,
                            label: String(localized: "Reminder", comment: "Important date detail: label for the reminder field"),
                            value: date.reminderEnabled
                                ? reminderLabel
                                : String(localized: "Off", comment: "Important date detail: reminder value when disabled")
                        )
                    }

                    // MARK: - Note

                    if let note = date.note, !note.isEmpty {
                        NoteSection(note: note)
                    }

                    // MARK: - Linked Gifts

                    if !linkedGifts.isEmpty {
                        giftIdeasSection
                    }

                    // MARK: - Delete

                    DeleteButton(label: String(localized: "Delete date", comment: "Important date detail: button to delete this date")) {
                        showingDeleteAlert = true
                    }
                }
                .padding(.horizontal, Spacing.xxxl)
                .padding(.top, Spacing.xxxl)
                .padding(.bottom, Spacing.screen)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.bgPrimary)
        .navigationBarBackButtonHidden(true)
        .background(SwipeBackEnabler())
        .navigationDestination(item: $selectedGiftIdea) { idea in
            GiftIdeaDetailView(idea: idea)
        }
        .sheet(isPresented: $showingEditSheet) {
            if let person = date.person {
                ImportantDateFormSheet(
                    person: person,
                    existingDate: date,
                    customCategories: customCategories
                )
            }
        }
        .deleteConfirmation(
            String(localized: "Delete date?", comment: "Delete confirmation: title for deleting a date"),
            isPresented: $showingDeleteAlert
        ) {
            NotificationService.shared.removeNotification(for: date)
            modelContext.delete(date)
            dismiss()
        }
    }

    // MARK: - Hero

    private var hero: some View {
        VStack(spacing: Spacing.lg) {
            // Large category icon
            IconBadge(
                systemName: date.categoryIcon,
                iconColor: date.categoryColor,
                backgroundColor: date.categoryColor.opacity(Opacity.iconBackground),
                size: 64,
                cornerRadius: CornerRadius.xl
            )

            // Countdown
            if !date.isPast {
                VStack(spacing: Spacing.xs) {
                    Text(countdownDisplay)
                        .font(.custom(FontFamily.display, size: 36, relativeTo: .largeTitle))
                        .foregroundStyle(Color.textPrimary)
                        .tracking(-0.3)

                    if !countdownUnit.isEmpty {
                        Text(countdownUnit)
                            .font(.custom(FontFamily.ui, size: 14, relativeTo: .subheadline))
                            .foregroundStyle(Color.textTertiary)
                    }
                }
            } else {
                Text(String(localized: "Passed", comment: "Date detail: label shown when a date has already passed"))
                    .font(.custom(FontFamily.ui, size: 14, relativeTo: .subheadline))
                    .fontWeight(.medium)
                    .foregroundStyle(Color.textTertiary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.xxl)
        .background(Color.bgSurface)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: CornerRadius.lg)
                .strokeBorder(Color.borderSubtle, lineWidth: 1)
        )
    }

    private var reminderLabel: String {
        let days = date.reminderDaysBefore
        if days == 0 { return String(localized: "On the day", comment: "Reminder option: notify on the date itself") }
        if days == 1 { return String(localized: "1 day before", comment: "Reminder option: notify 1 day before") }
        if days == 7 { return String(localized: "1 week before", comment: "Reminder option: notify 1 week before") }
        if days == 14 { return String(localized: "2 weeks before", comment: "Reminder option: notify 2 weeks before") }
        if days == 30 { return String(localized: "1 month before", comment: "Reminder option: notify 1 month before") }
        return String(localized: "\(days) days before", comment: "Reminder option: notify N days before the date")
    }

    private var countdownDisplay: String {
        let days = date.daysUntilNext
        if days == 0 { return String(localized: "Today", comment: "Date detail: countdown showing the date is today") }
        return "\(days)"
    }

    private var countdownUnit: String {
        let days = date.daysUntilNext
        if days == 0 { return "" }
        if days == 1 {
            return String(localized: "day away", comment: "Date detail: singular countdown unit")
        }
        return String(localized: "days away", comment: "Date detail: plural countdown unit")
    }

    // MARK: - Linked Gifts

    private var linkedGifts: [GiftIdea] {
        guard let person = date.person else { return [] }
        return (person.giftIdeas ?? [])
            .filter { $0.linkedDate?.persistentModelID == date.persistentModelID }
            .sorted { $0.createdAt > $1.createdAt }
    }

    private var giftIdeasSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack(spacing: Spacing.sm) {
                Image(systemName: "gift")
                    .font(.custom(FontFamily.ui, size: 12, relativeTo: .caption))
                    .foregroundStyle(Color.textTertiary)
                Text(String(localized: "Gift ideas", comment: "Date detail: section header for linked gift ideas"))
                    .font(.sectionLabel)
                    .foregroundStyle(Color.textTertiary)
            }

            VStack(spacing: Spacing.sm) {
                ForEach(linkedGifts) { idea in
                    giftIdeaRow(idea)
                }
            }
        }
    }

    private func giftIdeaRow(_ idea: GiftIdea) -> some View {
        Button(action: { selectedGiftIdea = idea }, label: {
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
    }
}
