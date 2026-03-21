import Testing
@testable import yours

@MainActor
struct GlobalSearchServiceTests {
    // MARK: - Empty & Blank Queries

    @Test func emptyQueryReturnsNoResults() {
        let context = TestSupport.makeContext()
        let person = TestSupport.seedPerson(in: context)
        TestSupport.seedNote(in: context, body: "Something searchable", person: person)

        let results = GlobalSearchService.search(query: "", person: person)
        #expect(results.isEmpty)
    }

    // MARK: - Section Coverage

    @Test func searchFindsNotes() {
        let context = TestSupport.makeContext()
        let person = TestSupport.seedPerson(in: context)
        TestSupport.seedNote(in: context, body: "Birthday party planning", person: person)

        let groups = GlobalSearchService.search(query: "birthday", person: person)
        #expect(groups.count == 1)
        #expect(groups[0].id == "notes")
        #expect(groups[0].results[0].title.contains("Birthday"))
    }

    @Test func searchFindsGiftIdeas() {
        let context = TestSupport.makeContext()
        let person = TestSupport.seedPerson(in: context)
        TestSupport.seedGiftIdea(in: context, title: "Wireless headphones", person: person)

        let groups = GlobalSearchService.search(query: "wireless", person: person)
        #expect(groups.count == 1)
        #expect(groups[0].id == "giftIdeas")
    }

    @Test func searchFindsImportantDates() {
        let context = TestSupport.makeContext()
        let person = TestSupport.seedPerson(in: context)
        TestSupport.seedImportantDate(in: context, title: "Wedding anniversary", person: person)

        let groups = GlobalSearchService.search(query: "wedding", person: person)
        #expect(groups.count == 1)
        #expect(groups[0].id == "importantDates")
    }

    @Test func searchFindsAskAboutItems() {
        let context = TestSupport.makeContext()
        let person = TestSupport.seedPerson(in: context)
        TestSupport.seedAskAboutItem(in: context, title: "New job update", person: person)

        let groups = GlobalSearchService.search(query: "job", person: person)
        #expect(groups.count == 1)
        #expect(groups[0].id == "askAbout")
    }

    @Test func searchFindsQuirks() {
        let context = TestSupport.makeContext()
        let person = TestSupport.seedPerson(in: context)
        TestSupport.seedQuirk(in: context, text: "Always taps fingers", person: person)

        let groups = GlobalSearchService.search(query: "taps", person: person)
        #expect(groups.count == 1)
        #expect(groups[0].id == "quirks")
    }

    @Test func searchFindsLikes() {
        let context = TestSupport.makeContext()
        let person = TestSupport.seedPerson(in: context)
        TestSupport.seedLikeDislike(in: context, name: "Dark chocolate", kind: .like, person: person)

        let groups = GlobalSearchService.search(query: "chocolate", person: person)
        #expect(groups.count == 1)
        #expect(groups[0].id == "likes")
    }

    @Test func searchFindsDislikes() {
        let context = TestSupport.makeContext()
        let person = TestSupport.seedPerson(in: context)
        TestSupport.seedLikeDislike(in: context, name: "Loud music", kind: .dislike, person: person)

        let groups = GlobalSearchService.search(query: "loud", person: person)
        #expect(groups.count == 1)
        #expect(groups[0].id == "dislikes")
    }

    @Test func searchFindsTheirPeople() {
        let context = TestSupport.makeContext()
        let person = TestSupport.seedPerson(in: context)
        TestSupport.seedTheirPeople(in: context, name: "Uncle Roberto", person: person)

        let groups = GlobalSearchService.search(query: "roberto", person: person)
        #expect(groups.count == 1)
        #expect(groups[0].id == "theirPeople")
    }

    @Test func searchFindsAllergies() {
        let context = TestSupport.makeContext()
        let person = TestSupport.seedPerson(in: context)
        TestSupport.seedAllergy(in: context, name: "Peanuts", person: person)

        let groups = GlobalSearchService.search(query: "peanut", person: person)
        #expect(groups.count == 1)
        #expect(groups[0].id == "allergies")
    }

    @Test func searchFindsFoodOrders() {
        let context = TestSupport.makeContext()
        let person = TestSupport.seedPerson(in: context)
        TestSupport.seedFoodOrder(in: context, place: "Starbucks", order: "Oat latte", person: person)

        let groups = GlobalSearchService.search(query: "starbucks", person: person)
        #expect(groups.count == 1)
        #expect(groups[0].id == "foodOrders")
    }

    @Test func searchFindsClothingSizes() {
        let context = TestSupport.makeContext()
        let person = TestSupport.seedPerson(in: context)
        TestSupport.seedClothingSize(in: context, size: "XL", person: person)

        let groups = GlobalSearchService.search(query: "XL", person: person)
        #expect(groups.count == 1)
        #expect(groups[0].id == "sizes")
    }

    // MARK: - Search Behavior

    @Test func searchIsCaseInsensitive() {
        let context = TestSupport.makeContext()
        let person = TestSupport.seedPerson(in: context)
        TestSupport.seedNote(in: context, body: "UPPERCASE content", person: person)

        let groups = GlobalSearchService.search(query: "uppercase", person: person)
        #expect(groups.count == 1)
    }

    @Test func searchReturnsMultipleSections() {
        let context = TestSupport.makeContext()
        let person = TestSupport.seedPerson(in: context)
        TestSupport.seedNote(in: context, body: "Pizza night plan", person: person)
        TestSupport.seedFoodOrder(in: context, place: "Pizza Hut", order: "Large pepperoni", person: person)

        let groups = GlobalSearchService.search(query: "pizza", person: person)
        #expect(groups.count == 2)
        let ids = Set(groups.map(\.id))
        #expect(ids.contains("notes"))
        #expect(ids.contains("foodOrders"))
    }

    @Test func searchRespectsMaxResultsPerSection() {
        let context = TestSupport.makeContext()
        let person = TestSupport.seedPerson(in: context)
        for i in 0 ..< 10 {
            TestSupport.seedNote(in: context, body: "Matching note \(i)", person: person)
        }

        let groups = GlobalSearchService.search(query: "matching", person: person)
        #expect(groups.count == 1)
        #expect(groups[0].results.count == GlobalSearchService.maxResultsPerSection)
    }

    @Test func noMatchReturnsEmpty() {
        let context = TestSupport.makeContext()
        let person = TestSupport.seedPerson(in: context)
        TestSupport.seedNote(in: context, body: "Something else", person: person)

        let groups = GlobalSearchService.search(query: "zzzznotfound", person: person)
        #expect(groups.isEmpty)
    }

    // MARK: - Config Integrity

    @Test func allSectionIdsAreUnique() {
        let ids = GlobalSearchService.sections.map(\.id)
        #expect(Set(ids).count == ids.count)
    }

    @Test func searchFindsDreams() {
        let context = TestSupport.makeContext()
        let person = TestSupport.seedPerson(in: context)
        TestSupport.seedDream(in: context, text: "Publish a novel", person: person)

        let groups = GlobalSearchService.search(query: "novel", person: person)
        #expect(groups.count == 1)
        #expect(groups[0].id == "dreams")
    }

    @Test func sectionCountMatchesExpected() {
        #expect(GlobalSearchService.sections.count == 12)
    }
}
