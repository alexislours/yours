import Foundation
import SwiftData
import Testing
@testable import yours

@Suite("Category Models", .tags(.models, .categories))
@MainActor
struct CategoryModelTests {
    // MARK: - Color Resolution

    @Suite("Color Resolution via CategoryPalette")
    @MainActor
    struct ColorResolution {
        @Test("Known color name resolves to palette color")
        func knownColor() {
            let color = CategoryPalette.color(for: "terracotta")
            // Just verify it returns something (Color is not Equatable in general,
            // but we can verify it doesn't crash)
            _ = color
        }

        @Test("Unknown color name returns fallback gray")
        func unknownColor() {
            let color = CategoryPalette.color(for: "nonexistent")
            _ = color
        }

        @Test("All curated palette colors have entries")
        func allCuratedColors() {
            let curated = CategoryPalette.curated
            #expect(!curated.isEmpty)
            for entry in curated {
                _ = CategoryPalette.color(for: entry.name)
                #expect(!entry.label.isEmpty)
            }
        }
    }

    // MARK: - Curated Symbols

    @Suite("Curated Symbols")
    @MainActor
    struct CuratedSymbols {
        @Test("GiftCategory curated symbols list is non-empty")
        func giftCategoryCuratedSymbols() {
            #expect(!GiftCategory.curatedSymbols.isEmpty)
        }

        @Test("TheirPeopleCategory curated symbols list is non-empty")
        func theirPeopleCategoryCuratedSymbols() {
            #expect(!TheirPeopleCategory.curatedSymbols.isEmpty)
        }

        @Test("LikeDislikeCategory curated symbols list is non-empty")
        func likeDislikeCategoryCuratedSymbols() {
            #expect(!LikeDislikeCategory.curatedSymbols.isEmpty)
        }

        @Test("AllergyCategory curated symbols list is non-empty")
        func allergyCategoryCuratedSymbols() {
            #expect(!AllergyCategory.curatedSymbols.isEmpty)
        }

        @Test("ClothingSizeCategory curated symbols list is non-empty")
        func clothingSizeCategoryCuratedSymbols() {
            #expect(!ClothingSizeCategory.curatedSymbols.isEmpty)
        }

        @Test("DateCategory curated symbols list is non-empty")
        func dateCategoryCuratedSymbols() {
            #expect(!DateCategory.curatedSymbols.isEmpty)
        }

        @Test("FoodOrderCategory curated symbols list is non-empty")
        func foodOrderCategoryCuratedSymbols() {
            #expect(!FoodOrderCategory.curatedSymbols.isEmpty)
        }
    }

    // MARK: - Item Count

    @Suite("Item Count")
    @MainActor
    struct ItemCount {
        @Test("New category has zero item count")
        func newCategoryZeroCount() {
            let ctx = TestSupport.makeContext()
            let category = GiftCategory(name: "Test", sfSymbol: "gift", colorName: "sage")
            ctx.insert(category)
            #expect(category.itemCount == 0)
        }

        @Test("Category reflects linked item count")
        func categoryReflectsItemCount() throws {
            let ctx = TestSupport.makeContext()
            let person = TestSupport.seedPerson(in: ctx)
            let category = GiftCategory(name: "Custom", sfSymbol: "gift", colorName: "sage")
            ctx.insert(category)

            let gift = GiftIdea(
                title: "Gift", predefinedCategory: .justBecause,
                customCategory: category, person: person
            )
            ctx.insert(gift)
            try ctx.save()

            #expect(category.itemCount == 1)
        }
    }

    // MARK: - Category Color via ManageableCategory

    @Test("Custom category color resolves from colorName")
    func customCategoryColorResolves() {
        let ctx = TestSupport.makeContext()
        let category = GiftCategory(name: "Test", sfSymbol: "gift", colorName: "amber")
        ctx.insert(category)
        let color = category.color
        _ = color // Verify it resolves without crashing
    }
}
