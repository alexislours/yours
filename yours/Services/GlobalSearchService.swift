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
    private static let maxResultsPerSection = 5

    static func search(query: String, person: Person) -> [SearchResultGroup] {
        guard !query.isEmpty else { return [] }

        return [
            searchNotes(query: query, person: person),
            searchGiftIdeas(query: query, person: person),
            searchImportantDates(query: query, person: person),
            searchAskAboutItems(query: query, person: person),
            searchQuirks(query: query, person: person),
            searchLikes(query: query, person: person),
            searchDislikes(query: query, person: person),
            searchTheirPeople(query: query, person: person),
            searchAllergies(query: query, person: person),
            searchFoodOrders(query: query, person: person),
            searchClothingSizes(query: query, person: person),
        ].compactMap(\.self)
    }
}

// MARK: - Section Searches

extension GlobalSearchService {
    private static func searchNotes(query: String, person: Person) -> SearchResultGroup? {
        let matches = (person.notes ?? []).filter {
            $0.body.localizedCaseInsensitiveContains(query)
        }
        guard !matches.isEmpty else { return nil }
        return SearchResultGroup(
            id: "notes",
            sectionTitle: String(localized: "Notes", comment: "Search: notes section header"),
            sectionIcon: "note.text",
            sectionIconColor: Color(.caution),
            sectionIconBackground: Color(.cautionSoft),
            results: matches.prefix(maxResultsPerSection).map { note in
                SearchResult(
                    id: "note-\(note.id)",
                    title: note.firstLine,
                    subtitle: note.formattedDate,
                    destination: .notes
                )
            }
        )
    }

    private static func searchGiftIdeas(query: String, person: Person) -> SearchResultGroup? {
        let matches = (person.giftIdeas ?? []).filter {
            $0.title.localizedCaseInsensitiveContains(query)
                || ($0.note ?? "").localizedCaseInsensitiveContains(query)
        }
        guard !matches.isEmpty else { return nil }
        return SearchResultGroup(
            id: "giftIdeas",
            sectionTitle: String(localized: "Gift ideas", comment: "Search: gift ideas section header"),
            sectionIcon: "lightbulb",
            sectionIconColor: .accentRose,
            sectionIconBackground: .accentRoseSoft,
            results: matches.prefix(maxResultsPerSection).map { idea in
                SearchResult(
                    id: "gift-\(idea.id)",
                    title: idea.title,
                    subtitle: idea.note,
                    destination: .giftIdeaDetail(idea)
                )
            }
        )
    }

    private static func searchImportantDates(query: String, person: Person) -> SearchResultGroup? {
        let matches = (person.importantDates ?? []).filter {
            $0.title.localizedCaseInsensitiveContains(query)
        }
        guard !matches.isEmpty else { return nil }
        return SearchResultGroup(
            id: "importantDates",
            sectionTitle: String(
                localized: "Important dates",
                comment: "Search: important dates section header"
            ),
            sectionIcon: "calendar",
            sectionIconColor: .accentSecondary,
            sectionIconBackground: .accentSecondarySoft,
            results: matches.prefix(maxResultsPerSection).map { date in
                SearchResult(
                    id: "date-\(date.id)",
                    title: date.title,
                    subtitle: date.countdownText,
                    destination: .importantDateDetail(date)
                )
            }
        )
    }

    private static func searchAskAboutItems(query: String, person: Person) -> SearchResultGroup? {
        let matches = (person.askAboutItems ?? []).filter {
            $0.title.localizedCaseInsensitiveContains(query)
        }
        guard !matches.isEmpty else { return nil }
        return SearchResultGroup(
            id: "askAbout",
            sectionTitle: String(localized: "Ask about", comment: "Search: ask about section header"),
            sectionIcon: "bubble.left.and.text.bubble.right",
            sectionIconColor: Color(.caution),
            sectionIconBackground: Color(.cautionSoft),
            results: matches.prefix(maxResultsPerSection).map { item in
                SearchResult(
                    id: "ask-\(item.id)",
                    title: item.title,
                    subtitle: nil,
                    destination: .askAbout
                )
            }
        )
    }

    private static func searchQuirks(query: String, person: Person) -> SearchResultGroup? {
        let matches = (person.quirks ?? []).filter {
            $0.text.localizedCaseInsensitiveContains(query)
        }
        guard !matches.isEmpty else { return nil }
        return SearchResultGroup(
            id: "quirks",
            sectionTitle: String(
                localized: "Quirks & Habits",
                comment: "Search: quirks section header"
            ),
            sectionIcon: "eyes",
            sectionIconColor: Color(.caution),
            sectionIconBackground: Color(.cautionSoft),
            results: matches.prefix(maxResultsPerSection).map { quirk in
                SearchResult(
                    id: "quirk-\(quirk.id)",
                    title: quirk.text,
                    subtitle: nil,
                    destination: .quirks
                )
            }
        )
    }

    private static func searchLikes(query: String, person: Person) -> SearchResultGroup? {
        let matches = person.likes.filter {
            $0.name.localizedCaseInsensitiveContains(query)
                || ($0.note ?? "").localizedCaseInsensitiveContains(query)
        }
        guard !matches.isEmpty else { return nil }
        return SearchResultGroup(
            id: "likes",
            sectionTitle: String(localized: "Likes", comment: "Search: likes section header"),
            sectionIcon: "heart.fill",
            sectionIconColor: .accentSecondary,
            sectionIconBackground: .accentSecondarySoft,
            results: matches.prefix(maxResultsPerSection).map { item in
                SearchResult(
                    id: "like-\(item.id)",
                    title: item.name,
                    subtitle: item.note,
                    destination: .likes
                )
            }
        )
    }

    private static func searchDislikes(query: String, person: Person) -> SearchResultGroup? {
        let matches = person.dislikes.filter {
            $0.name.localizedCaseInsensitiveContains(query)
                || ($0.note ?? "").localizedCaseInsensitiveContains(query)
        }
        guard !matches.isEmpty else { return nil }
        return SearchResultGroup(
            id: "dislikes",
            sectionTitle: String(localized: "Dislikes", comment: "Search: dislikes section header"),
            sectionIcon: "heart.slash",
            sectionIconColor: .accentRose,
            sectionIconBackground: .accentRoseSoft,
            results: matches.prefix(maxResultsPerSection).map { item in
                SearchResult(
                    id: "dislike-\(item.id)",
                    title: item.name,
                    subtitle: item.note,
                    destination: .dislikes
                )
            }
        )
    }

    private static func searchTheirPeople(query: String, person: Person) -> SearchResultGroup? {
        let matches = (person.theirPeopleItems ?? []).filter {
            $0.name.localizedCaseInsensitiveContains(query)
                || ($0.note ?? "").localizedCaseInsensitiveContains(query)
        }
        guard !matches.isEmpty else { return nil }
        return SearchResultGroup(
            id: "theirPeople",
            sectionTitle: String(localized: "People", comment: "Search: people section header"),
            sectionIcon: "person.2.fill",
            sectionIconColor: CategoryPalette.color(for: "lavender"),
            sectionIconBackground: CategoryPalette.color(for: "lavender").opacity(Opacity.iconBackground),
            results: matches.prefix(maxResultsPerSection).map { item in
                SearchResult(
                    id: "person-\(item.id)",
                    title: item.name,
                    subtitle: item.note,
                    destination: .theirPeople
                )
            }
        )
    }

    private static func searchAllergies(query: String, person: Person) -> SearchResultGroup? {
        let matches = (person.allergyItems ?? []).filter {
            $0.name.localizedCaseInsensitiveContains(query)
                || ($0.note ?? "").localizedCaseInsensitiveContains(query)
        }
        guard !matches.isEmpty else { return nil }
        return SearchResultGroup(
            id: "allergies",
            sectionTitle: String(localized: "Allergies", comment: "Search: allergies section header"),
            sectionIcon: "cross.case.fill",
            sectionIconColor: CategoryPalette.color(for: "amber"),
            sectionIconBackground: CategoryPalette.color(for: "amber").opacity(Opacity.iconBackground),
            results: matches.prefix(maxResultsPerSection).map { item in
                SearchResult(
                    id: "allergy-\(item.id)",
                    title: item.name,
                    subtitle: item.note,
                    destination: .allergies
                )
            }
        )
    }

    private static func searchFoodOrders(query: String, person: Person) -> SearchResultGroup? {
        let matches = (person.foodOrderItems ?? []).filter {
            $0.place.localizedCaseInsensitiveContains(query)
                || $0.order.localizedCaseInsensitiveContains(query)
                || ($0.note ?? "").localizedCaseInsensitiveContains(query)
        }
        guard !matches.isEmpty else { return nil }
        return SearchResultGroup(
            id: "foodOrders",
            sectionTitle: String(
                localized: "Food orders",
                comment: "Search: food orders section header"
            ),
            sectionIcon: "menucard.fill",
            sectionIconColor: CategoryPalette.color(for: "eucalyptus"),
            sectionIconBackground: CategoryPalette.color(for: "eucalyptus").opacity(Opacity.iconBackground),
            results: matches.prefix(maxResultsPerSection).map { item in
                SearchResult(
                    id: "food-\(item.id)",
                    title: item.place,
                    subtitle: item.order,
                    destination: .foodOrders
                )
            }
        )
    }

    private static func searchClothingSizes(query: String, person: Person) -> SearchResultGroup? {
        let matches = (person.clothingSizeItems ?? []).filter {
            $0.size.localizedCaseInsensitiveContains(query)
                || ($0.note ?? "").localizedCaseInsensitiveContains(query)
        }
        guard !matches.isEmpty else { return nil }
        return SearchResultGroup(
            id: "sizes",
            sectionTitle: String(localized: "Sizes", comment: "Search: sizes section header"),
            sectionIcon: "ruler",
            sectionIconColor: CategoryPalette.color(for: "sage"),
            sectionIconBackground: CategoryPalette.color(for: "sage").opacity(Opacity.iconBackground),
            results: matches.prefix(maxResultsPerSection).map { item in
                SearchResult(
                    id: "size-\(item.id)",
                    title: item.size,
                    subtitle: item.note,
                    destination: .sizes
                )
            }
        )
    }
}
