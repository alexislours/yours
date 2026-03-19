import SwiftUI

struct HomeView: View {
    let person: Person
    let pendingQuickActionType: String?
    @Binding var deepLink: DeepLink?
    @Binding var navigationPath: NavigationPath

    @State private var searchText = ""
    @State private var isSearchActive = false

    enum HomeDestination: Hashable {
        case newNote
        case newAskAbout
        case newQuirk
        case newGiftIdea
        case importantDates
        case settings
        case notes
        case quirks
        case askAbout
        case giftIdeas
        case likes
        case dislikes
        case allergies
        case foodOrders
        case sizes
        case theirPeople
        case giftIdeaDetail(GiftIdea)
        case importantDateDetail(ImportantDate)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.xxxl) {
                ProfileHeader(
                    person: person,
                    reminder: birthdayReminder,
                    onSettingsTapped: { navigationPath.append(HomeDestination.settings) }
                )

                // Divider
                Rectangle()
                    .fill(Color.borderSubtle)
                    .frame(height: 1)
                    .accessibilityHidden(true)

                searchBarPlaceholder

                // Section cards
                VStack(spacing: Spacing.md) {
                    importantDatesCard
                    aboutCard
                    quirksCard
                    giftIdeasCard
                    askAboutCard
                    notesCard
                }
            }
            .padding(.horizontal, Spacing.xxxl)
            .padding(.bottom, Spacing.block)
        }
        .background(Color.bgPrimary)
        .overlay {
            if isSearchActive {
                searchOverlay
                    .transition(.opacity)
            }
        }
        .navigationDestination(for: HomeDestination.self) { destination in
            switch destination {
            case .newNote:
                NotesView(person: person, startWithNewNote: true)
            case .newAskAbout:
                AskAboutView(person: person, startFocused: true)
            case .newQuirk:
                QuirksView(person: person, startWithNewQuirk: true)
            case .newGiftIdea:
                GiftIdeasView(person: person, startWithNewIdea: true)
            case .importantDates:
                ImportantDatesView(person: person)
            case .settings:
                SettingsView()
            case .notes:
                NotesView(person: person)
            case .quirks:
                QuirksView(person: person)
            case .askAbout:
                AskAboutView(person: person)
            case .giftIdeas:
                GiftIdeasView(person: person)
            case .likes:
                LikesDislikesListView(person: person, kind: .likes)
            case .dislikes:
                LikesDislikesListView(person: person, kind: .dislikes)
            case .allergies:
                AllergiesListView(person: person)
            case .foodOrders:
                FoodOrdersView(person: person)
            case .sizes:
                SizesGridView(person: person)
            case .theirPeople:
                TheirPeopleListView(person: person)
            case let .giftIdeaDetail(idea):
                GiftIdeaDetailView(idea: idea)
            case let .importantDateDetail(date):
                ImportantDateDetailView(date: date)
            }
        }
        .task {
            handleQuickAction(pendingQuickActionType)
        }
        .onReceive(NotificationCenter.default.publisher(for: .quickActionTriggered)) { notification in
            handleQuickAction(notification.object as? String)
        }
        .onChange(of: deepLink) {
            handleDeepLink()
        }
        .onAppear {
            handleDeepLink()
        }
    }

    private func handleQuickAction(_ type: String?) {
        guard let type, let action = QuickAction(rawValue: type) else { return }
        switch action {
        case .addNote:
            navigationPath.append(HomeDestination.newNote)
        case .addGiftIdea:
            navigationPath.append(HomeDestination.newGiftIdea)
        }
    }

    private func handleDeepLink() {
        guard let deepLink else { return }
        self.deepLink = nil
        navigationPath = NavigationPath()
        switch deepLink {
        case .home:
            break
        case .importantDates:
            navigationPath.append(HomeDestination.importantDates)
        }
    }

    private var birthdayReminder: ProfileHeader.Reminder? {
        guard let days = person.daysUntilBirthday, days <= 60 else { return nil }
        let text = if days == 0 {
            person.gendered(
                female: String(localized: "Her birthday is today!", comment: "Home: birthday today, female"),
                male: String(localized: "His birthday is today!", comment: "Home: birthday today, male"),
                other: String(localized: "Their birthday is today!", comment: "Home: birthday today, non-binary")
            )
        } else if days == 1 {
            person.gendered(
                female: String(localized: "Her birthday is tomorrow", comment: "Home: birthday tomorrow, female"),
                male: String(localized: "His birthday is tomorrow", comment: "Home: birthday tomorrow, male"),
                other: String(localized: "Their birthday is tomorrow", comment: "Home: birthday tomorrow, non-binary")
            )
        } else {
            person.gendered(
                female: String(localized: "Her birthday is in \(days) days", comment: "Home: birthday countdown, female"),
                male: String(localized: "His birthday is in \(days) days", comment: "Home: birthday countdown, male"),
                other: String(localized: "Their birthday is in \(days) days", comment: "Home: birthday countdown, non-binary")
            )
        }
        return .init(icon: "gift", text: text, color: .accentPrimary)
    }

    // MARK: - Search

    private var searchBarPlaceholder: some View {
        Button { withAnimation(.expandCollapse) { isSearchActive = true } } label: {
            HStack(spacing: Spacing.sm) {
                Image(systemName: "magnifyingglass")
                    .font(.custom(FontFamily.ui, size: 14, relativeTo: .subheadline))
                    .foregroundStyle(Color.textTertiary)
                Text(String(
                    localized: "Search everything",
                    comment: "Home: global search placeholder"
                ))
                .font(.bodyDefault)
                .foregroundStyle(Color.textTertiary)
                Spacer()
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.md)
            .background(Color.bgSurface)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.lg)
                    .strokeBorder(Color.borderSubtle, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(
            String(localized: "Search everything", comment: "Accessibility: open global search")
        )
    }

    private var searchOverlay: some View {
        VStack(spacing: 0) {
            HStack(spacing: Spacing.md) {
                SearchBar(
                    placeholder: String(
                        localized: "Search everything",
                        comment: "Home: global search placeholder"
                    ),
                    text: $searchText,
                    requestFocus: true
                )
                Button { dismissSearch() } label: {
                    Image(systemName: "xmark")
                        .font(.custom(FontFamily.ui, size: 14, relativeTo: .subheadline).weight(.medium))
                        .foregroundStyle(Color.textSecondary)
                        .frame(width: 32, height: 32)
                        .background(Color.bgSurface, in: Circle())
                        .overlay(Circle().strokeBorder(Color.borderSubtle, lineWidth: 1))
                }
                .frame(minWidth: 44, minHeight: 44)
                .contentShape(Circle())
                .accessibilityLabel(
                    String(localized: "Close search", comment: "Accessibility: close global search")
                )
            }
            .padding(.horizontal, Spacing.xxxl)
            .padding(.top, Spacing.lg)
            .padding(.bottom, Spacing.xxl)

            SearchResultsOverlay(
                searchText: $searchText,
                person: person,
                onSelect: { destination in
                    dismissSearch()
                    navigationPath.append(destination)
                }
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.bgPrimary)
    }

    private func dismissSearch() {
        withAnimation(.expandCollapse) {
            searchText = ""
            isSearchActive = false
        }
    }
}
