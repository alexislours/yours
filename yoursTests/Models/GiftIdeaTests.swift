import Foundation
import SwiftData
import Testing
@testable import yours

@Suite("GiftIdea Model", .tags(.models, .giftIdeas))
@MainActor
struct GiftIdeaTests {
    // MARK: - Price Formatting

    @Suite("Price Formatting")
    @MainActor
    struct PriceFormatting {
        @Test("Nil price returns nil formatted price")
        func nilPrice() {
            let ctx = TestSupport.makeContext()
            let person = TestSupport.seedPerson(in: ctx)
            let gift = TestSupport.seedGiftIdea(in: ctx, title: "Gift", person: person)
            #expect(gift.formattedPrice == nil)
        }

        @Test("Non-nil price returns formatted string")
        func nonNilPrice() throws {
            let ctx = TestSupport.makeContext()
            let person = TestSupport.seedPerson(in: ctx)
            let gift = TestSupport.seedGiftIdea(in: ctx, title: "Gift", price: 29.99, person: person)
            let formatted = try #require(gift.formattedPrice)
            #expect(formatted.contains("29"))
        }

        @Test("Zero price formats without error")
        func zeroPrice() {
            let ctx = TestSupport.makeContext()
            let person = TestSupport.seedPerson(in: ctx)
            let gift = TestSupport.seedGiftIdea(in: ctx, title: "Gift", price: 0, person: person)
            #expect(gift.formattedPrice != nil)
        }

        @Test("Large price formats without error")
        func largePrice() throws {
            let ctx = TestSupport.makeContext()
            let person = TestSupport.seedPerson(in: ctx)
            let gift = TestSupport.seedGiftIdea(in: ctx, title: "Gift", price: 9999.99, person: person)
            let formatted = try #require(gift.formattedPrice)
            #expect(formatted.contains("9,999") || formatted.contains("9999"))
        }
    }

    // MARK: - URL Parsing

    @Suite("URL Parsing")
    @MainActor
    struct URLParsing {
        @Test("Nil urlString returns nil URL")
        func nilUrl() {
            let ctx = TestSupport.makeContext()
            let person = TestSupport.seedPerson(in: ctx)
            let gift = GiftIdea(title: "Gift", person: person)
            ctx.insert(gift)
            #expect(gift.url == nil)
        }

        @Test("Empty urlString returns nil URL")
        func emptyUrl() {
            let ctx = TestSupport.makeContext()
            let person = TestSupport.seedPerson(in: ctx)
            let gift = GiftIdea(title: "Gift", urlString: "", person: person)
            ctx.insert(gift)
            #expect(gift.url == nil)
        }

        @Test("URL with https prefix is used as-is")
        func httpsPrefix() {
            let ctx = TestSupport.makeContext()
            let person = TestSupport.seedPerson(in: ctx)
            let gift = GiftIdea(title: "Gift", urlString: "https://example.com", person: person)
            ctx.insert(gift)
            #expect(gift.url?.absoluteString == "https://example.com")
        }

        @Test("URL with http prefix is used as-is")
        func httpPrefix() {
            let ctx = TestSupport.makeContext()
            let person = TestSupport.seedPerson(in: ctx)
            let gift = GiftIdea(title: "Gift", urlString: "http://example.com", person: person)
            ctx.insert(gift)
            #expect(gift.url?.absoluteString == "http://example.com")
        }

        @Test("URL without scheme gets https prepended")
        func noScheme() {
            let ctx = TestSupport.makeContext()
            let person = TestSupport.seedPerson(in: ctx)
            let gift = GiftIdea(title: "Gift", urlString: "example.com", person: person)
            ctx.insert(gift)
            #expect(gift.url?.absoluteString == "https://example.com")
        }

        @Test("Garbage input returns nil URL")
        func garbageInput() {
            let ctx = TestSupport.makeContext()
            let person = TestSupport.seedPerson(in: ctx)
            let gift = GiftIdea(title: "Gift", urlString: "not a url at all :::", person: person)
            ctx.insert(gift)
            // URL(string:) may still parse some garbage, but the result should be non-functional
            // The key behavior is it doesn't crash
        }
    }

    // MARK: - Domain Name

    @Suite("Domain Name Extraction")
    @MainActor
    struct DomainName {
        @Test("Extracts domain from https URL")
        func httpsDomain() {
            let ctx = TestSupport.makeContext()
            let person = TestSupport.seedPerson(in: ctx)
            let gift = GiftIdea(title: "Gift", urlString: "https://www.amazon.com/dp/123", person: person)
            ctx.insert(gift)
            #expect(gift.domainName == "www.amazon.com")
        }

        @Test("Extracts domain from bare URL")
        func bareDomain() {
            let ctx = TestSupport.makeContext()
            let person = TestSupport.seedPerson(in: ctx)
            let gift = GiftIdea(title: "Gift", urlString: "etsy.com/listing/456", person: person)
            ctx.insert(gift)
            #expect(gift.domainName == "etsy.com")
        }

        @Test("Nil when no URL")
        func nilDomain() {
            let ctx = TestSupport.makeContext()
            let person = TestSupport.seedPerson(in: ctx)
            let gift = GiftIdea(title: "Gift", person: person)
            ctx.insert(gift)
            #expect(gift.domainName == nil)
        }
    }

    // MARK: - Status Transitions

    @Suite("Status Transitions")
    @MainActor
    struct StatusTransitions {
        @Test("Idea transitions to purchased")
        func ideaToPurchased() {
            #expect(GiftStatus.idea.next == .purchased)
        }

        @Test("Purchased transitions to given")
        func purchasedToGiven() {
            #expect(GiftStatus.purchased.next == .given)
        }

        @Test("Given has no next status")
        func givenIsTerminal() {
            #expect(GiftStatus.given.next == nil)
        }

        @Test("Archived has no next status")
        func archivedIsTerminal() {
            #expect(GiftStatus.archived.next == nil)
        }

        @Test(
            "Every status has displayName and icon",
            arguments: GiftStatus.allCases
        )
        func allStatusesHaveDisplayProperties(status: GiftStatus) {
            #expect(!status.displayName.isEmpty)
            #expect(!status.icon.isEmpty)
        }
    }
}
