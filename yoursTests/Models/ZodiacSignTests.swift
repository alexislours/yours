import Testing
@testable import yours

@Suite("ZodiacSign", .tags(.models, .zodiac))
@MainActor
struct ZodiacSignTests {
    @Test(
        "All 12 signs resolve correctly from month/day pairs",
        arguments: [
            (3, 25, ZodiacSign.aries),
            (4, 25, ZodiacSign.taurus),
            (5, 25, ZodiacSign.gemini),
            (6, 25, ZodiacSign.cancer),
            (7, 25, ZodiacSign.leo),
            (8, 25, ZodiacSign.virgo),
            (9, 25, ZodiacSign.libra),
            (10, 25, ZodiacSign.scorpio),
            (11, 25, ZodiacSign.sagittarius),
            (12, 25, ZodiacSign.capricorn),
            (1, 25, ZodiacSign.aquarius),
            (2, 25, ZodiacSign.pisces),
        ] as [(Int, Int, ZodiacSign)]
    )
    func allSignsResolve(month: Int, day: Int, expected: ZodiacSign) {
        #expect(ZodiacSign.from(month: month, day: day) == expected)
    }

    // MARK: - Boundary Dates

    @Suite("Boundary Dates")
    struct BoundaryDates {
        @Test("Jan 19 is Capricorn, Jan 20 is Aquarius")
        func capricornAquariusBoundary() {
            #expect(ZodiacSign.from(month: 1, day: 19) == .capricorn)
            #expect(ZodiacSign.from(month: 1, day: 20) == .aquarius)
        }

        @Test("Feb 18 is Aquarius, Feb 19 is Pisces")
        func aquariusPiscesBoundary() {
            #expect(ZodiacSign.from(month: 2, day: 18) == .aquarius)
            #expect(ZodiacSign.from(month: 2, day: 19) == .pisces)
        }

        @Test("Mar 20 is Pisces, Mar 21 is Aries")
        func piscesAriesBoundary() {
            #expect(ZodiacSign.from(month: 3, day: 20) == .pisces)
            #expect(ZodiacSign.from(month: 3, day: 21) == .aries)
        }

        @Test("Apr 19 is Aries, Apr 20 is Taurus")
        func ariesTaurusBoundary() {
            #expect(ZodiacSign.from(month: 4, day: 19) == .aries)
            #expect(ZodiacSign.from(month: 4, day: 20) == .taurus)
        }

        @Test("May 20 is Taurus, May 21 is Gemini")
        func taurusGeminiBoundary() {
            #expect(ZodiacSign.from(month: 5, day: 20) == .taurus)
            #expect(ZodiacSign.from(month: 5, day: 21) == .gemini)
        }

        @Test("Jun 20 is Gemini, Jun 21 is Cancer")
        func geminiCancerBoundary() {
            #expect(ZodiacSign.from(month: 6, day: 20) == .gemini)
            #expect(ZodiacSign.from(month: 6, day: 21) == .cancer)
        }

        @Test("Jul 22 is Cancer, Jul 23 is Leo")
        func cancerLeoBoundary() {
            #expect(ZodiacSign.from(month: 7, day: 22) == .cancer)
            #expect(ZodiacSign.from(month: 7, day: 23) == .leo)
        }

        @Test("Aug 22 is Leo, Aug 23 is Virgo")
        func leoVirgoBoundary() {
            #expect(ZodiacSign.from(month: 8, day: 22) == .leo)
            #expect(ZodiacSign.from(month: 8, day: 23) == .virgo)
        }

        @Test("Sep 22 is Virgo, Sep 23 is Libra")
        func virgoLibraBoundary() {
            #expect(ZodiacSign.from(month: 9, day: 22) == .virgo)
            #expect(ZodiacSign.from(month: 9, day: 23) == .libra)
        }

        @Test("Oct 22 is Libra, Oct 23 is Scorpio")
        func libraScorpioBoundary() {
            #expect(ZodiacSign.from(month: 10, day: 22) == .libra)
            #expect(ZodiacSign.from(month: 10, day: 23) == .scorpio)
        }

        @Test("Nov 21 is Scorpio, Nov 22 is Sagittarius")
        func scorpioSagittariusBoundary() {
            #expect(ZodiacSign.from(month: 11, day: 21) == .scorpio)
            #expect(ZodiacSign.from(month: 11, day: 22) == .sagittarius)
        }

        @Test("Dec 21 is Sagittarius, Dec 22 is Capricorn")
        func sagittariusCapricornBoundary() {
            #expect(ZodiacSign.from(month: 12, day: 21) == .sagittarius)
            #expect(ZodiacSign.from(month: 12, day: 22) == .capricorn)
        }
    }

    // MARK: - Edge Cases

    @Suite("Edge Cases")
    struct EdgeCases {
        @Test("Feb 29 resolves to Pisces")
        func feb29() {
            #expect(ZodiacSign.from(month: 2, day: 29) == .pisces)
        }

        @Test("Dec 31 resolves to Capricorn")
        func dec31() {
            #expect(ZodiacSign.from(month: 12, day: 31) == .capricorn)
        }

        @Test("Jan 1 resolves to Capricorn")
        func jan1() {
            #expect(ZodiacSign.from(month: 1, day: 1) == .capricorn)
        }
    }

    // MARK: - Display Properties

    @Test(
        "Every sign has a non-empty symbol and displayName",
        arguments: ZodiacSign.allCases
    )
    func displayProperties(sign: ZodiacSign) {
        #expect(!sign.symbol.isEmpty)
        #expect(!sign.displayName.isEmpty)
        #expect(!sign.label.isEmpty)
    }
}
