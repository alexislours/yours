import LinkPresentation
import SwiftData
import SwiftUI

struct GiftIdeaDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    let idea: GiftIdea
    @Query private var customCategories: [GiftCategory]

    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    @State private var selectedDate: ImportantDate?

    var body: some View {
        VStack(spacing: 0) {
            DetailHeader(title: Text(idea.title), dismiss: dismiss) {
                Button(action: { showingEditSheet = true }, label: {
                    Image(systemName: "pencil")
                        .font(.custom(FontFamily.ui, size: 16, relativeTo: .callout).weight(.medium))
                        .foregroundStyle(Color.textSecondary)
                })
                .accessibilityLabel(Text("Edit", comment: "Gift detail: edit button accessibility label"))
            }
            .padding(.horizontal, Spacing.xxxl)

            ScrollView {
                VStack(spacing: Spacing.xxxl) {
                    hero

                    VStack(spacing: Spacing.md) {
                        statusRow

                        InfoRow(
                            icon: idea.categoryIcon,
                            iconColor: idea.categoryColor,
                            label: String(localized: "Category", comment: "Gift idea detail: label for the category field"),
                            value: idea.categoryDisplayName
                        )

                        if let price = idea.formattedPrice {
                            InfoRow(
                                icon: "banknote",
                                iconColor: Color.accentSecondary,
                                label: String(localized: "Price", comment: "Gift idea detail: label for the price field"),
                                value: price
                            )
                        }

                        if let linkedDate = idea.linkedDate {
                            linkedDateRow(linkedDate)
                        }

                        if let url = idea.url {
                            urlRow(url)
                        }
                    }

                    if let note = idea.note, !note.isEmpty {
                        NoteSection(note: note)
                    }

                    DeleteButton(label: String(localized: "Delete idea", comment: "Gift idea detail: button to delete this gift idea")) {
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
        .navigationDestination(item: $selectedDate) { date in
            ImportantDateDetailView(date: date)
        }
        .sheet(isPresented: $showingEditSheet) {
            if let person = idea.person {
                GiftIdeaFormSheet(
                    person: person,
                    existingIdea: idea,
                    customCategories: customCategories
                )
            }
        }
        .deleteConfirmation(
            String(localized: "Delete idea?", comment: "Delete confirmation: title for deleting a gift idea"),
            isPresented: $showingDeleteAlert
        ) {
            modelContext.delete(idea)
            dismiss()
        }
    }

    // MARK: - Hero

    private var hero: some View {
        VStack(spacing: Spacing.lg) {
            IconBadge(
                systemName: idea.categoryIcon,
                iconColor: idea.categoryColor,
                backgroundColor: idea.categoryColor.opacity(Opacity.iconBackground),
                size: 64,
                cornerRadius: CornerRadius.xl
            )

            Text(idea.title)
                .font(.heading1)
                .foregroundStyle(Color.textPrimary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, Spacing.xl)
        .padding(.vertical, Spacing.xxl)
        .background(Color.bgSurface)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: CornerRadius.lg)
                .strokeBorder(Color.borderSubtle, lineWidth: 1)
        )
    }

    // MARK: - Status Row

    private let lifecycleStatuses: [GiftStatus] = [.idea, .purchased, .given]

    private var statusRow: some View {
        VStack(spacing: Spacing.md) {
            HStack(spacing: Spacing.sm) {
                Image(systemName: "arrow.right")
                    .font(.custom(FontFamily.ui, size: 11, relativeTo: .caption2))
                    .foregroundStyle(Color.textTertiary)
                Text(String(localized: "Status", comment: "Gift detail: status section label"))
                    .font(.sectionLabel)
                    .foregroundStyle(Color.textTertiary)
                Spacer()
            }

            HStack(spacing: 0) {
                ForEach(Array(lifecycleStatuses.enumerated()), id: \.element.rawValue) { index, status in
                    let isActive = idea.status == status
                    let isPast = lifecycleStatuses.firstIndex(of: idea.status).map { index < $0 } ?? false

                    Button {
                        if status == .given {
                            HapticFeedback.fire(.success)
                        } else {
                            HapticFeedback.impact(.light)
                        }
                        withOptionalAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            idea.status = status
                            idea.updatedAt = .now
                        }
                    } label: {
                        VStack(spacing: Spacing.xs) {
                            Image(systemName: isActive ? status.icon : (isPast ? "checkmark" : status.icon))
                                .font(.custom(FontFamily.ui, size: 14, relativeTo: .subheadline).weight(isActive ? .semibold : .regular))
                                .foregroundStyle(isActive ? status.color : (isPast ? Color(.positive) : Color.textTertiary))
                                .frame(width: 36, height: 36)
                                .background(
                                    isActive
                                        ? status.color.opacity(Opacity.subtleBorder)
                                        : (isPast ? Color(.positive).opacity(Opacity.subtleBackground) : Color.bgSurface),
                                    in: Circle()
                                )
                                .overlay(
                                    Circle()
                                        .strokeBorder(
                                            isActive
                                                ? status.color.opacity(0.3)
                                                : (isPast ? Color(.positive).opacity(Opacity.subtleBorder) : Color.borderSubtle),
                                            lineWidth: 1
                                        )
                                )

                            Text(status.displayName)
                                .font(.sectionLabel)
                                .fontWeight(isActive ? .semibold : .medium)
                                .foregroundStyle(isActive ? status.color : (isPast ? Color(.positive) : Color.textTertiary))
                        }
                        .frame(maxWidth: .infinity)
                        .scaleEffect(isActive ? 1.0 : (isPast ? 1.0 : 0.95))
                    }
                    .buttonStyle(.plain)

                    if index < lifecycleStatuses.count - 1 {
                        let connectorFilled = lifecycleStatuses.firstIndex(of: idea.status).map { index < $0 } ?? false

                        Rectangle()
                            .fill(connectorFilled ? Color(.positive).opacity(0.3) : Color.borderSubtle)
                            .frame(height: 1)
                            .frame(maxWidth: 32)
                            .offset(y: -8)
                            .animation(.motionAware(.easeInOut(duration: 0.3)), value: connectorFilled)
                    }
                }
            }
            .padding(.vertical, Spacing.md)
            .padding(.horizontal, Spacing.sm)
            .background(Color.bgSurface)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.lg)
                    .strokeBorder(Color.borderSubtle, lineWidth: 1)
            )
        }
    }

    // MARK: - Linked Date Row

    private func linkedDateRow(_ date: ImportantDate) -> some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack(spacing: Spacing.sm) {
                Image(systemName: "calendar")
                    .font(.custom(FontFamily.ui, size: 12, relativeTo: .caption))
                    .foregroundStyle(Color.textTertiary)
                Text(String(localized: "Linked date", comment: "Gift detail: linked date section label"))
                    .font(.sectionLabel)
                    .foregroundStyle(Color.textTertiary)
            }

            Button(action: { selectedDate = date }, label: {
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
                    }
                }
                .cardStyle()
            })
            .buttonStyle(.plain)
        }
    }

    // MARK: - URL Row

    private func urlRow(_ url: URL) -> some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack(spacing: Spacing.sm) {
                Image(systemName: "link")
                    .font(.custom(FontFamily.ui, size: 12, relativeTo: .caption))
                    .foregroundStyle(Color.textTertiary)
                Text(String(localized: "Link", comment: "Gift detail: link section label for URL"))
                    .font(.sectionLabel)
                    .foregroundStyle(Color.textTertiary)
            }

            LinkPreviewView(url: url)
                .frame(maxWidth: .infinity)
                .frame(minHeight: 60)
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.lg))
        }
    }
}
