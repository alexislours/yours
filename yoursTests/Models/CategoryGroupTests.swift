import Foundation
import SwiftData
import Testing
@testable import yours

@Suite("CategoryGroup", .tags(.models, .categories))
@MainActor
struct CategoryGroupTests {
    @Test("Items group correctly by predefined category")
    func groupsByCategory() {
        let ctx = TestSupport.makeContext()
        let person = TestSupport.seedPerson(in: ctx)

        let gift1 = GiftIdea(title: "Cake", predefinedCategory: .birthday, person: person)
        let gift2 = GiftIdea(title: "Flowers", predefinedCategory: .anniversary, person: person)
        let gift3 = GiftIdea(title: "Card", predefinedCategory: .birthday, person: person)
        ctx.insert(gift1)
        ctx.insert(gift2)
        ctx.insert(gift3)

        let groups = CategoryGroup.grouped(from: [gift1, gift2, gift3], sortedBy: \.title)
        #expect(groups.count == 2)
    }

    @Test("Groups sort alphabetically by name")
    func groupsSortAlphabetically() {
        let ctx = TestSupport.makeContext()
        let person = TestSupport.seedPerson(in: ctx)

        let gift1 = GiftIdea(title: "A", predefinedCategory: .holiday, person: person)
        let gift2 = GiftIdea(title: "B", predefinedCategory: .anniversary, person: person)
        ctx.insert(gift1)
        ctx.insert(gift2)

        let groups = CategoryGroup.grouped(from: [gift1, gift2], sortedBy: \.title)
        #expect(groups.count == 2)
        #expect(groups[0].name == "Anniversary")
        #expect(groups[1].name == "Holiday")
    }

    @Test("Items within groups sort by provided key path")
    func itemsSortWithinGroup() {
        let ctx = TestSupport.makeContext()
        let person = TestSupport.seedPerson(in: ctx)

        let gift1 = GiftIdea(title: "Zephyr", predefinedCategory: .birthday, person: person)
        let gift2 = GiftIdea(title: "Alpha", predefinedCategory: .birthday, person: person)
        ctx.insert(gift1)
        ctx.insert(gift2)

        let groups = CategoryGroup.grouped(from: [gift1, gift2], sortedBy: \.title)
        #expect(groups.count == 1)
        #expect(groups[0].items[0].title == "Alpha")
        #expect(groups[0].items[1].title == "Zephyr")
    }

    @Test("Empty input produces no groups")
    func emptyInput() {
        let groups = CategoryGroup<GiftIdea>.grouped(from: [], sortedBy: \.title)
        #expect(groups.isEmpty)
    }

    @Test("Group inherits category display name, icon, and color")
    func groupInheritsDisplayProperties() {
        let ctx = TestSupport.makeContext()
        let person = TestSupport.seedPerson(in: ctx)

        let gift = GiftIdea(title: "Test", predefinedCategory: .birthday, person: person)
        ctx.insert(gift)

        let groups = CategoryGroup.grouped(from: [gift], sortedBy: \.title)
        #expect(groups.count == 1)
        #expect(groups[0].name == GiftOccasion.birthday.displayName)
        #expect(groups[0].icon == GiftOccasion.birthday.icon)
    }

    @Test("Custom category items group separately from predefined")
    func customCategoryGroupsSeparately() {
        let ctx = TestSupport.makeContext()
        let person = TestSupport.seedPerson(in: ctx)

        let custom = GiftCategory(name: "Handmade", sfSymbol: "paintbrush.fill", colorName: "sage")
        ctx.insert(custom)

        let gift1 = GiftIdea(title: "Scarf", predefinedCategory: .birthday, person: person)
        let gift2 = GiftIdea(
            title: "Painting", predefinedCategory: .birthday,
            customCategory: custom, person: person
        )
        ctx.insert(gift1)
        ctx.insert(gift2)

        let groups = CategoryGroup.grouped(from: [gift1, gift2], sortedBy: \.title)
        #expect(groups.count == 2)
    }
}
