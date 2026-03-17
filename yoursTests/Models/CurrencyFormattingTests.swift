import Foundation
import Testing
@testable import yours

@Suite("CurrencyFormatting", .tags(.models, .formatting))
struct CurrencyFormattingTests {
    @Test("Formats a standard decimal value")
    func formatsStandard() throws {
        let result = try #require(CurrencyFormatting.format(29.99))
        #expect(result.contains("29"))
    }

    @Test("Formats zero")
    func formatsZero() {
        let result = CurrencyFormatting.format(0)
        #expect(result != nil)
    }

    @Test("Formats large numbers")
    func formatsLargeNumber() throws {
        let result = try #require(CurrencyFormatting.format(99999.99))
        #expect(result.contains("99"))
    }

    @Test("Currency code falls back to locale default")
    func fallsBackToLocale() {
        // With no UserDefaults override, it should fall back to locale
        let code = CurrencyFormatting.preferredCurrencyCode
        #expect(!code.isEmpty)
    }

    @Test("Currency symbol is non-empty")
    func symbolNonEmpty() {
        #expect(!CurrencyFormatting.preferredCurrencySymbol.isEmpty)
    }
}
