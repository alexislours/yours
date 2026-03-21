import SwiftUI

struct SearchResult: Identifiable {
    let id: String
    let title: String
    let subtitle: String?
    let destination: HomeView.HomeDestination
}

struct SearchResultGroup: Identifiable {
    let id: String
    let sectionTitle: String
    let sectionIcon: String
    let sectionIconColor: Color
    let sectionIconBackground: Color
    let results: [SearchResult]
}

enum GlobalSearchService {
    static let maxResultsPerSection = 5

    static func search(query: String, person: Person) -> [SearchResultGroup] {
        guard !query.isEmpty else { return [] }
        return sections.compactMap { config in
            let results = config.search(person, query)
            guard !results.isEmpty else { return nil }
            return SearchResultGroup(
                id: config.id,
                sectionTitle: config.sectionTitle,
                sectionIcon: config.sectionIcon,
                sectionIconColor: config.sectionIconColor,
                sectionIconBackground: config.sectionIconBackground,
                results: Array(results.prefix(maxResultsPerSection))
            )
        }
    }
}

// MARK: - Section Configuration

extension GlobalSearchService {
    struct SearchSectionConfig {
        let id: String
        let sectionTitle: String
        let sectionIcon: String
        let sectionIconColor: Color
        let sectionIconBackground: Color
        let search: (Person, String) -> [SearchResult]
    }

    private static func notesSections() -> [SearchSectionConfig] {
        let notesSection = SearchSectionConfig(
            id: "notes",
            sectionTitle: String(localized: "Notes", comment: "Search: notes section header"),
            sectionIcon: "note.text",
            sectionIconColor: Color(.caution),
            sectionIconBackground: Color(.cautionSoft),
            search: { person, query in
                (person.notes ?? [])
                    .filter { $0.body.localizedCaseInsensitiveContains(query) }
                    .map { SearchResult(id: "note-\($0.id)", title: $0.firstLine, subtitle: $0.formattedDate, destination: .notes) }
            }
        )

        let giftIdeasSection = SearchSectionConfig(
            id: "giftIdeas",
            sectionTitle: String(localized: "Gift ideas", comment: "Search: gift ideas section header"),
            sectionIcon: "lightbulb",
            sectionIconColor: .accentRose,
            sectionIconBackground: .accentRoseSoft,
            search: { person, query in
                (person.giftIdeas ?? [])
                    .filter {
                        $0.title.localizedCaseInsensitiveContains(query)
                            || ($0.note ?? "").localizedCaseInsensitiveContains(query)
                    }
                    .map {
                        SearchResult(id: "gift-\($0.id)", title: $0.title, subtitle: $0.note, destination: .giftIdeaDetail($0))
                    }
            }
        )

        let importantDatesSection = SearchSectionConfig(
            id: "importantDates",
            sectionTitle: String(localized: "Important dates", comment: "Search: important dates section header"),
            sectionIcon: "calendar",
            sectionIconColor: .accentSecondary,
            sectionIconBackground: .accentSecondarySoft,
            search: { person, query in
                (person.importantDates ?? [])
                    .filter { $0.title.localizedCaseInsensitiveContains(query) }
                    .map {
                        SearchResult(
                            id: "date-\($0.id)",
                            title: $0.title,
                            subtitle: $0.countdownText,
                            destination: .importantDateDetail($0)
                        )
                    }
            }
        )

        let askAboutSection = SearchSectionConfig(
            id: "askAbout",
            sectionTitle: String(localized: "Ask about", comment: "Search: ask about section header"),
            sectionIcon: "bubble.left.and.text.bubble.right",
            sectionIconColor: Color(.caution),
            sectionIconBackground: Color(.cautionSoft),
            search: { person, query in
                (person.askAboutItems ?? [])
                    .filter { $0.title.localizedCaseInsensitiveContains(query) }
                    .map { SearchResult(id: "ask-\($0.id)", title: $0.title, subtitle: nil, destination: .askAbout) }
            }
        )

        return [notesSection, giftIdeasSection, importantDatesSection, askAboutSection]
    }

    private static func peopleSections() -> [SearchSectionConfig] {
        let quirksSection = SearchSectionConfig(
            id: "quirks",
            sectionTitle: String(localized: "Quirks & Habits", comment: "Search: quirks section header"),
            sectionIcon: "eyes",
            sectionIconColor: Color(.caution),
            sectionIconBackground: Color(.cautionSoft),
            search: { person, query in
                (person.quirks ?? [])
                    .filter { $0.text.localizedCaseInsensitiveContains(query) }
                    .map { SearchResult(id: "quirk-\($0.id)", title: $0.text, subtitle: nil, destination: .quirks) }
            }
        )

        let likesSection = SearchSectionConfig(
            id: "likes",
            sectionTitle: String(localized: "Likes", comment: "Search: likes section header"),
            sectionIcon: "heart.fill",
            sectionIconColor: .accentSecondary,
            sectionIconBackground: .accentSecondarySoft,
            search: { person, query in
                person.likes
                    .filter {
                        $0.name.localizedCaseInsensitiveContains(query)
                            || ($0.note ?? "").localizedCaseInsensitiveContains(query)
                    }
                    .map { SearchResult(id: "like-\($0.id)", title: $0.name, subtitle: $0.note, destination: .likes) }
            }
        )

        let dislikesSection = SearchSectionConfig(
            id: "dislikes",
            sectionTitle: String(localized: "Dislikes", comment: "Search: dislikes section header"),
            sectionIcon: "heart.slash",
            sectionIconColor: .accentRose,
            sectionIconBackground: .accentRoseSoft,
            search: { person, query in
                person.dislikes
                    .filter {
                        $0.name.localizedCaseInsensitiveContains(query)
                            || ($0.note ?? "").localizedCaseInsensitiveContains(query)
                    }
                    .map { SearchResult(id: "dislike-\($0.id)", title: $0.name, subtitle: $0.note, destination: .dislikes) }
            }
        )

        let theirPeopleSection = SearchSectionConfig(
            id: "theirPeople",
            sectionTitle: String(localized: "People", comment: "Search: people section header"),
            sectionIcon: "person.2.fill",
            sectionIconColor: CategoryPalette.color(for: "lavender"),
            sectionIconBackground: CategoryPalette.color(for: "lavender").opacity(Opacity.iconBackground),
            search: { person, query in
                (person.theirPeopleItems ?? [])
                    .filter {
                        $0.name.localizedCaseInsensitiveContains(query)
                            || ($0.note ?? "").localizedCaseInsensitiveContains(query)
                    }
                    .map { SearchResult(id: "person-\($0.id)", title: $0.name, subtitle: $0.note, destination: .theirPeople) }
            }
        )

        let petNamesSection = SearchSectionConfig(
            id: "petNames",
            sectionTitle: String(localized: "Pet Names", comment: "Search: pet names section header"),
            sectionIcon: "heart.text.clipboard",
            sectionIconColor: CategoryPalette.color(for: "rose"),
            sectionIconBackground: CategoryPalette.color(for: "rose").opacity(Opacity.iconBackground),
            search: { person, query in
                (person.petNames ?? [])
                    .filter { $0.text.localizedCaseInsensitiveContains(query) }
                    .map { SearchResult(id: "petname-\($0.id)", title: $0.text, subtitle: nil, destination: .petNames) }
            }
        )

        return [quirksSection, likesSection, dislikesSection, theirPeopleSection, petNamesSection]
    }

    private static func lifestyleSections() -> [SearchSectionConfig] {
        let allergiesSection = SearchSectionConfig(
            id: "allergies",
            sectionTitle: String(localized: "Allergies", comment: "Search: allergies section header"),
            sectionIcon: "cross.case.fill",
            sectionIconColor: CategoryPalette.color(for: "amber"),
            sectionIconBackground: CategoryPalette.color(for: "amber").opacity(Opacity.iconBackground),
            search: { person, query in
                (person.allergyItems ?? [])
                    .filter {
                        $0.name.localizedCaseInsensitiveContains(query)
                            || ($0.note ?? "").localizedCaseInsensitiveContains(query)
                    }
                    .map { SearchResult(id: "allergy-\($0.id)", title: $0.name, subtitle: $0.note, destination: .allergies) }
            }
        )

        let foodOrdersSection = SearchSectionConfig(
            id: "foodOrders",
            sectionTitle: String(localized: "Food orders", comment: "Search: food orders section header"),
            sectionIcon: "menucard.fill",
            sectionIconColor: CategoryPalette.color(for: "eucalyptus"),
            sectionIconBackground: CategoryPalette.color(for: "eucalyptus").opacity(Opacity.iconBackground),
            search: { person, query in
                (person.foodOrderItems ?? [])
                    .filter {
                        $0.place.localizedCaseInsensitiveContains(query)
                            || $0.order.localizedCaseInsensitiveContains(query)
                            || ($0.note ?? "").localizedCaseInsensitiveContains(query)
                    }
                    .map { SearchResult(id: "food-\($0.id)", title: $0.place, subtitle: $0.order, destination: .foodOrders) }
            }
        )

        let sizesSection = SearchSectionConfig(
            id: "sizes",
            sectionTitle: String(localized: "Sizes", comment: "Search: sizes section header"),
            sectionIcon: "ruler",
            sectionIconColor: CategoryPalette.color(for: "sage"),
            sectionIconBackground: CategoryPalette.color(for: "sage").opacity(Opacity.iconBackground),
            search: { person, query in
                (person.clothingSizeItems ?? [])
                    .filter {
                        $0.size.localizedCaseInsensitiveContains(query)
                            || ($0.note ?? "").localizedCaseInsensitiveContains(query)
                    }
                    .map { SearchResult(id: "size-\($0.id)", title: $0.size, subtitle: $0.note, destination: .sizes) }
            }
        )

        return [allergiesSection, foodOrdersSection, sizesSection]
    }

    static let sections: [SearchSectionConfig] = notesSections() + peopleSections() + lifestyleSections()
}
