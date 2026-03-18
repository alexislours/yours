import SwiftUI

// MARK: - Section Cards

extension HomeView {
    var importantDatesCard: some View {
        NavigationLink(destination: ImportantDatesView(person: person)) {
            SectionCard(
                title: String(localized: "Important dates", comment: "Home: important dates card title"),
                icon: "calendar",
                iconColor: Color.accentSecondary,
                iconBackground: Color.accentSecondarySoft
            ) {
                if let nearest = person.nearestDate {
                    SectionCardPreviewRow(
                        preview: "\(nearest.title), \(nearest.countdownText)",
                        badge: person.importantDateCount > 0
                            ? String(localized: "\(person.importantDateCount) dates", comment: "Home: important dates badge count")
                            : nil
                    )
                }
            }
        }
        .buttonStyle(.pressable)
        .accessibilityIdentifier("card-important-dates")
    }

    var giftIdeasCard: some View {
        let giftIdeaCount = person.giftIdeaCount
        return NavigationLink(destination: GiftIdeasView(person: person)) {
            SectionCard(
                title: String(localized: "Gift ideas", comment: "Home: gift ideas card title"),
                icon: "lightbulb",
                iconColor: Color.accentRose,
                iconBackground: Color.accentRoseSoft
            ) {
                if let latest = person.latestGiftIdea {
                    SectionCardPreviewRow(
                        preview: latest.title,
                        // swiftlint:disable:next line_length
                        badge: giftIdeaCount > 0 ? String(localized: "\(giftIdeaCount) ideas", comment: "Home: gift ideas badge count") : nil
                    )
                }
            }
        }
        .buttonStyle(.pressable)
        .accessibilityIdentifier("card-gift-ideas")
    }

    var askAboutCard: some View {
        let askAboutCount = person.askAboutItemCount
        return NavigationLink(destination: AskAboutView(person: person)) {
            SectionCard(
                title: person.gendered(
                    female: String(localized: "Ask her about", comment: "Home: ask-about card title, female"),
                    male: String(localized: "Ask him about", comment: "Home: ask-about card title, male"),
                    other: String(localized: "Ask them about", comment: "Home: ask-about card title, non-binary")
                ),
                icon: "bubble.left.and.text.bubble.right",
                iconColor: Color(.caution),
                iconBackground: Color(.cautionSoft),
                showAddButton: askAboutCount > 0,
                onAdd: { navigationPath.append(HomeDestination.newAskAbout) },
                content: {
                    if askAboutCount > 0 {
                        SectionCardPreviewRow(
                            preview: String(localized: "\(askAboutCount) things to ask about", comment: "Home: ask-about preview count"),
                            badge: nil
                        )
                    }
                }
            )
        }
        .buttonStyle(.pressable)
    }

    var aboutCard: some View {
        NavigationLink(destination: AboutView(person: person)) {
            SectionCard(
                title: String(
                    localized: "All about \(person.firstName)",
                    comment: "Home: card title for about section with person's name"
                ),
                icon: "heart",
                iconColor: Color.accentSecondary,
                iconBackground: Color.accentSecondarySoft
            ) {
                EmptyView()
            }
        }
        .buttonStyle(.pressable)
        .accessibilityIdentifier("card-about")
    }

    var quirksCard: some View {
        NavigationLink(destination: QuirksView(person: person)) {
            SectionCard(
                title: String(localized: "Quirks & Habits", comment: "Home card: quirks section title"),
                icon: "eyes",
                iconColor: Color(.caution),
                iconBackground: Color(.cautionSoft),
                showAddButton: person.quirkCount > 0,
                onAdd: { navigationPath.append(HomeDestination.newQuirk) },
                content: {
                    if let latest = person.latestQuirk {
                        SectionCardPreviewRow(
                            preview: latest.text,
                            badge: person.quirkCount > 0 ? "\(person.quirkCount)" : nil
                        )
                    }
                }
            )
        }
        .buttonStyle(.pressable)
    }

    var notesCard: some View {
        NavigationLink(destination: NotesView(person: person)) {
            SectionCard(
                title: String(localized: "Notes", comment: "Home card: notes section title"),
                icon: "note.text",
                iconColor: Color(.caution),
                iconBackground: Color(.cautionSoft),
                showAddButton: person.latestNote != nil,
                onAdd: { navigationPath.append(HomeDestination.newNote) },
                content: {
                    if let latest = person.latestNote {
                        SectionCardBodyRow(
                            text: latest.firstLine,
                            timestamp: latest.formattedDate
                        )
                    }
                }
            )
        }
        .buttonStyle(.pressable)
    }
}

#Preview {
    HomeView(
        person: .preview,
        pendingQuickActionType: nil,
        deepLink: .constant(nil),
        navigationPath: .constant(NavigationPath())
    )
}
