import Foundation
import SwiftData
import Testing
@testable import yours

@Suite("TheirPeopleItem Model", .tags(.models, .theirPeople))
@MainActor
struct TheirPeopleItemTests {
    // MARK: - Family Grouping

    @Suite("Family Grouping")
    @MainActor
    struct FamilyGrouping {
        @Test(
            "Family categories group under family key",
            arguments: [
                TheirPeoplePredefinedCategory.mom,
                .dad,
                .sibling,
                .grandparent,
                .extendedFamily,
            ]
        )
        func familyCategoriesGroupTogether(category: TheirPeoplePredefinedCategory) {
            let ctx = TestSupport.makeContext()
            let person = TestSupport.seedPerson(in: ctx)
            let item = TheirPeopleItem(name: "Test", predefinedCategory: category, person: person)
            ctx.insert(item)
            #expect(item.categoryGroupKey == "family")
            #expect(item.isInFamilyGroup)
        }

        @Test(
            "Non-family categories use their own key",
            arguments: [
                TheirPeoplePredefinedCategory.child,
                .friend,
                .coworker,
                .other,
            ]
        )
        func nonFamilyCategoriesStaySeparate(category: TheirPeoplePredefinedCategory) {
            let ctx = TestSupport.makeContext()
            let person = TestSupport.seedPerson(in: ctx)
            let item = TheirPeopleItem(name: "Test", predefinedCategory: category, person: person)
            ctx.insert(item)
            #expect(item.categoryGroupKey == category.rawValue)
            #expect(!item.isInFamilyGroup)
        }

        @Test("Custom categories are never treated as family")
        func customCategoryNotFamily() {
            let ctx = TestSupport.makeContext()
            let person = TestSupport.seedPerson(in: ctx)
            let custom = TheirPeopleCategory(name: "Custom", sfSymbol: "star", colorName: "sage")
            ctx.insert(custom)
            let item = TheirPeopleItem(
                name: "Test", predefinedCategory: .mom,
                customCategory: custom, person: person
            )
            ctx.insert(item)
            #expect(!item.isInFamilyGroup)
            #expect(item.categoryGroupKey.hasPrefix("custom:"))
        }
    }

    // MARK: - Family Sort Order

    @Suite("Family Sort Order")
    @MainActor
    struct FamilySortOrder {
        @Test("Mom sorts before Dad")
        func momBeforeDad() {
            #expect(
                TheirPeoplePredefinedCategory.mom.familySortOrder
                    < TheirPeoplePredefinedCategory.dad.familySortOrder
            )
        }

        @Test("Dad sorts before Sibling")
        func dadBeforeSibling() {
            #expect(
                TheirPeoplePredefinedCategory.dad.familySortOrder
                    < TheirPeoplePredefinedCategory.sibling.familySortOrder
            )
        }

        @Test("Sibling sorts before Grandparent")
        func siblingBeforeGrandparent() {
            #expect(
                TheirPeoplePredefinedCategory.sibling.familySortOrder
                    < TheirPeoplePredefinedCategory.grandparent.familySortOrder
            )
        }

        @Test("Grandparent sorts before Extended Family")
        func grandparentBeforeExtendedFamily() {
            #expect(
                TheirPeoplePredefinedCategory.grandparent.familySortOrder
                    < TheirPeoplePredefinedCategory.extendedFamily.familySortOrder
            )
        }

        @Test("Family sort order is consistent via items")
        func familySortOrderOnItems() {
            let ctx = TestSupport.makeContext()
            let person = TestSupport.seedPerson(in: ctx)

            let mom = TheirPeopleItem(name: "Mom", predefinedCategory: .mom, person: person)
            let dad = TheirPeopleItem(name: "Dad", predefinedCategory: .dad, person: person)
            let sibling = TheirPeopleItem(
                name: "Sibling", predefinedCategory: .sibling, person: person
            )
            ctx.insert(mom)
            ctx.insert(dad)
            ctx.insert(sibling)

            #expect(mom.familySortOrder < dad.familySortOrder)
            #expect(dad.familySortOrder < sibling.familySortOrder)
        }
    }

    // MARK: - Relationship Tag

    @Suite("Relationship Tag")
    @MainActor
    struct RelationshipTag {
        @Test("Family members have relationship tag")
        func familyHasTag() {
            let ctx = TestSupport.makeContext()
            let person = TestSupport.seedPerson(in: ctx)
            let item = TheirPeopleItem(name: "Test", predefinedCategory: .mom, person: person)
            ctx.insert(item)
            #expect(item.relationshipTag == "Mom")
        }

        @Test("Non-family members have no relationship tag")
        func nonFamilyNoTag() {
            let ctx = TestSupport.makeContext()
            let person = TestSupport.seedPerson(in: ctx)
            let item = TheirPeopleItem(name: "Test", predefinedCategory: .friend, person: person)
            ctx.insert(item)
            #expect(item.relationshipTag == nil)
        }
    }
}
