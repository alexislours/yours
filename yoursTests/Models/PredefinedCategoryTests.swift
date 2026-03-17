import Testing
@testable import yours

@Suite("Predefined Category Enums", .tags(.models, .categories))
@MainActor
struct PredefinedCategoryTests {
    // MARK: - filterByVisibility

    @Suite("filterByVisibility")
    @MainActor
    struct FilterByVisibility {
        @Test("Empty hidden string returns all visible")
        func emptyHiddenString() {
            let result = GiftOccasion.filterByVisibility(hiddenRaw: "")
            #expect(result.visible.count == GiftOccasion.allCases.count)
            #expect(result.hidden.isEmpty)
        }

        @Test("Hidden raw string hides matching categories")
        func hidesMatchingCategories() {
            let result = GiftOccasion.filterByVisibility(hiddenRaw: "birthday,holiday")
            #expect(result.visible.count == 2)
            #expect(result.hidden.count == 2)
            #expect(!result.visible.contains(.birthday))
            #expect(!result.visible.contains(.holiday))
            #expect(result.visible.contains(.anniversary))
            #expect(result.visible.contains(.justBecause))
        }

        @Test("Unknown raw values in hidden string are ignored")
        func unknownValuesIgnored() {
            let result = GiftOccasion.filterByVisibility(hiddenRaw: "nonexistent")
            #expect(result.visible.count == GiftOccasion.allCases.count)
            #expect(result.hidden.isEmpty)
        }

        @Test("Works with LikeDislikePredefinedCategory")
        func worksWithLikeDislike() {
            let result = LikeDislikePredefinedCategory.filterByVisibility(hiddenRaw: "music,travel")
            #expect(!result.visible.contains(.music))
            #expect(!result.visible.contains(.travel))
            #expect(result.hidden.count == 2)
        }
    }

    // MARK: - Display Properties

    @Suite("Display Properties")
    @MainActor
    struct DisplayProperties {
        @Test(
            "Every GiftOccasion has non-empty displayName and icon",
            arguments: GiftOccasion.allCases
        )
        func giftOccasionDisplayProperties(occasion: GiftOccasion) {
            #expect(!occasion.displayName.isEmpty)
            #expect(!occasion.icon.isEmpty)
            #expect(!occasion.colorName.isEmpty)
        }

        @Test(
            "Every TheirPeoplePredefinedCategory has non-empty displayName and icon",
            arguments: TheirPeoplePredefinedCategory.allCases
        )
        func theirPeopleDisplayProperties(category: TheirPeoplePredefinedCategory) {
            #expect(!category.displayName.isEmpty)
            #expect(!category.icon.isEmpty)
            #expect(!category.colorName.isEmpty)
        }

        @Test(
            "Every LikeDislikePredefinedCategory has non-empty displayName and icon",
            arguments: LikeDislikePredefinedCategory.allCases
        )
        func likeDislikeDisplayProperties(category: LikeDislikePredefinedCategory) {
            #expect(!category.displayName.isEmpty)
            #expect(!category.icon.isEmpty)
            #expect(!category.colorName.isEmpty)
        }

        @Test(
            "Every ImportantDatePredefinedCategory has non-empty displayName and icon",
            arguments: ImportantDatePredefinedCategory.allCases
        )
        func importantDateDisplayProperties(category: ImportantDatePredefinedCategory) {
            #expect(!category.displayName.isEmpty)
            #expect(!category.icon.isEmpty)
            #expect(!category.colorName.isEmpty)
        }
    }
}
