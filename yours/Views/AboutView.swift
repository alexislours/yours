import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    let person: Person

    @State private var showingBirthdayPicker = false
    @State private var avatarImage: Image?
    @State private var showCard = false
    @State var showLikesCards = false
    @State private var emptyStateAppeared = false

    var body: some View {
        Group {
            if showCard {
                ScrollView {
                    VStack(spacing: Spacing.xxxl) {
                        DetailHeader(
                            title: aboutTitle,
                            dismiss: dismiss
                        )

                        profileCard
                            .transition(.blurReplace.combined(with: .scale(0.92)))

                        VStack(spacing: Spacing.md) {
                            likesDislikesCards

                            sizesAndPeopleCards

                            allergiesAndOrdersCards

                            petNamesAndDreamsCards
                        }
                    }
                    .padding(.horizontal, Spacing.xxxl)
                }
                .transition(.opacity)
            } else {
                VStack(spacing: Spacing.xxxl) {
                    DetailHeader(
                        title: aboutTitle,
                        dismiss: dismiss
                    )

                    Spacer()

                    emptyState

                    Spacer()
                }
                .padding(.horizontal, Spacing.xxxl)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.bgPrimary)
        .navigationBarBackButtonHidden(true)
        .background(SwipeBackEnabler())
        .sheet(isPresented: $showingBirthdayPicker, onDismiss: {
            withOptionalAnimation(.easeInOut(duration: 0.45)) {
                showCard = person.birthday != nil
            }
            if person.birthday != nil {
                Task {
                    try? await Task.sleep(for: .seconds(0.3))
                    showLikesCards = true
                }
            }
        }, content: {
            BirthdayPickerSheet(person: person)
        })
        .onAppear {
            showCard = person.birthday != nil
            showLikesCards = person.birthday != nil
        }
        .task {
            guard let data = person.photoData else { return }
            if let decoded = await decodeImage(from: data) {
                avatarImage = decoded
            }
        }
    }

    // MARK: - Title

    private var aboutTitle: Text {
        styledTitle(String(
            localized: "About \(person.firstName)",
            comment: "About view: header with person's name - translators can reorder"
        ))
    }

    private var tellUsAboutTitle: Text {
        styledTitle(String(
            localized: "Tell us about \(person.firstName)",
            comment: "About view: empty state heading with person's name - translators can reorder"
        ))
    }

    private func styledTitle(_ fullString: String) -> Text {
        var attributed = AttributedString(fullString)
        if let range = attributed.range(of: person.firstName) {
            attributed[range].foregroundColor = Color.accentPrimary
        }
        return Text(attributed)
    }

    // MARK: - Likes & Dislikes Cards

    private var likesDislikesCards: some View {
        let likes = person.likes
        let dislikes = person.dislikes
        return HStack(spacing: Spacing.md) {
            NavigationLink(destination: LikesDislikesListView(person: person, kind: .likes)) {
                AboutCard(
                    title: String(localized: "Likes", comment: "About: likes card title"),
                    icon: "heart.fill",
                    iconColor: .accentSecondary,
                    iconBackground: .accentSecondarySoft,
                    previewText: likes.first?.name,
                    countText: likes.isEmpty
                        ? nil
                        : String(localized: "\(likes.count) likes", comment: "About: likes count label")
                )
            }
            .buttonStyle(.plain)
            .opacity(showLikesCards ? 1 : 0)
            .offset(y: showLikesCards ? 0 : 12)
            .animation(.motionAware(.easeOut(duration: 0.4)), value: showLikesCards)

            NavigationLink(destination: LikesDislikesListView(person: person, kind: .dislikes)) {
                AboutCard(
                    title: String(localized: "Dislikes", comment: "About: dislikes card title"),
                    icon: "heart.slash",
                    iconColor: .accentRose,
                    iconBackground: .accentRoseSoft,
                    previewText: dislikes.first?.name,
                    countText: dislikes.isEmpty
                        ? nil
                        : String(localized: "\(dislikes.count) dislikes", comment: "About: dislikes count label")
                )
            }
            .buttonStyle(.plain)
            .opacity(showLikesCards ? 1 : 0)
            .offset(y: showLikesCards ? 0 : 12)
            .animation(.motionAware(.easeOut(duration: 0.4).delay(0.1)), value: showLikesCards)
        }
    }

    // MARK: - Sizes & People Cards

    private var sizesAndPeopleCards: some View {
        let theirPeople = person.theirPeopleItems ?? []
        let sizeItems = person.clothingSizeItems ?? []
        let firstSize = sizeItems.first
        return HStack(spacing: Spacing.md) {
            NavigationLink(destination: SizesGridView(person: person)) {
                AboutCard(
                    title: String(localized: "Sizes", comment: "About: sizes card title"),
                    icon: "ruler",
                    iconColor: CategoryPalette.color(for: "sage"),
                    iconBackground: CategoryPalette.color(for: "sage").opacity(Opacity.iconBackground),
                    previewText: firstSize.map { "\($0.predefinedCategory.displayName): \($0.size)" },
                    countText: sizeItems.isEmpty
                        ? nil
                        : String(
                            localized: "\(sizeItems.count) sizes",
                            comment: "About: sizes count label"
                        )
                )
            }
            .buttonStyle(.plain)

            NavigationLink(destination: TheirPeopleListView(person: person)) {
                AboutCard(
                    title: String(localized: "People", comment: "About: people card title"),
                    icon: "person.2.fill",
                    iconColor: CategoryPalette.color(for: "lavender"),
                    iconBackground: CategoryPalette.color(for: "lavender").opacity(Opacity.iconBackground),
                    previewText: theirPeople.first?.name,
                    countText: {
                        let count = theirPeople.count
                        return count > 0
                            ? String(localized: "\(count) people", comment: "About: people count label")
                            : nil
                    }()
                )
            }
            .buttonStyle(.plain)
        }
        .opacity(showLikesCards ? 1 : 0)
        .offset(y: showLikesCards ? 0 : 12)
        .animation(.motionAware(.easeOut(duration: 0.4).delay(0.2)), value: showLikesCards)
    }

    // MARK: - Profile Card

    private var profileCard: some View {
        VStack(spacing: Spacing.lg) {
            AvatarView(name: person.firstName, size: 80, image: avatarImage)

            // Birthday
            VStack(spacing: Spacing.xs) {
                HStack(spacing: Spacing.xs) {
                    Text(String(localized: "BIRTHDAY", comment: "About: birthday section header"))
                        .font(.sectionLabel)
                        .foregroundStyle(Color.textTertiary)

                    Spacer()

                    Button { showingBirthdayPicker = true } label: {
                        Image(systemName: "pencil")
                            .font(.custom(FontFamily.ui, size: 14, relativeTo: .subheadline).weight(.medium))
                            .foregroundStyle(Color.textTertiary)
                    }
                }

                Text(person.formattedBirthday ?? "")
                    .font(.heading3)
                    .foregroundStyle(Color.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            // Age & Zodiac
            HStack(spacing: 0) {
                if let age = person.age {
                    infoItem(
                        value: "\(age)",
                        label: String(localized: "years old", comment: "About: age label below number"),
                        icon: "birthday.cake"
                    )
                    .frame(maxWidth: .infinity)
                }

                if person.age != nil, person.zodiacSign != nil {
                    Divider()
                        .frame(height: 32)
                }

                if let zodiac = person.zodiacSign {
                    infoItem(
                        value: zodiac.symbol,
                        label: zodiac.displayName,
                        icon: nil
                    )
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(Spacing.xxl)
        .frame(maxWidth: .infinity)
        .background(Color.bgSurfaceWarm, in: RoundedRectangle(cornerRadius: CornerRadius.xl))
        .overlay(
            RoundedRectangle(cornerRadius: CornerRadius.xl)
                .strokeBorder(Color.borderSubtle, lineWidth: 1)
        )
    }

    private func infoItem(value: String, label: String, icon: String?) -> some View {
        HStack(spacing: Spacing.sm) {
            if let icon {
                Image(systemName: icon)
                    .font(.custom(FontFamily.ui, size: 16, relativeTo: .callout).weight(.light))
                    .foregroundStyle(Color.textTertiary)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.heading3)
                    .foregroundStyle(Color.textPrimary)
                Text(label)
                    .font(.caption)
                    .foregroundStyle(Color.textTertiary)
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: Spacing.lg) {
            Image(systemName: "heart")
                .font(.custom(FontFamily.ui, size: 40, relativeTo: .largeTitle).weight(.light))
                .foregroundStyle(Color.accentSecondary)

            VStack(spacing: Spacing.sm) {
                tellUsAboutTitle
                    .font(.heading3)
                    .foregroundStyle(Color.textPrimary)

                // swiftlint:disable line_length
                Text(person.gendered(
                    female: String(localized: "Her favorites, quirks, the little things that make her who she is. Keep it all in one place.", comment: "About: empty state description, female"),
                    male: String(localized: "His favorites, quirks, the little things that make him who he is. Keep it all in one place.", comment: "About: empty state description, male"),
                    other: String(localized: "Their favorites, quirks, the little things that make them who they are. Keep it all in one place.", comment: "About: empty state description, non-binary")
                ))
                // swiftlint:enable line_length
                .font(.bodySmall)
                .foregroundStyle(Color.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
            }

            Button {
                showingBirthdayPicker = true
            } label: {
                Text(String(localized: "Add details", comment: "About: button to start adding person details"))
                    .font(.label)
                    .foregroundStyle(Color.textOnAccent)
                    .padding(.horizontal, Spacing.xxl)
                    .padding(.vertical, Spacing.sm)
                    .background(Color.accentSecondary, in: Capsule())
            }
            .padding(.top, Spacing.xs)
        }
        .padding(.horizontal, Spacing.xxxl)
        .opacity(emptyStateAppeared ? 1 : 0)
        .offset(y: emptyStateAppeared ? 0 : 8)
        .onAppear {
            withOptionalAnimation(.emptyState) {
                emptyStateAppeared = true
            }
        }
    }
}

#Preview {
    AboutView(person: .preview)
}
