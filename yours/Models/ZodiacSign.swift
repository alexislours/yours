import Foundation

enum ZodiacSign: String, CaseIterable {
    case aries, taurus, gemini, cancer, leo, virgo
    case libra, scorpio, sagittarius, capricorn, aquarius, pisces

    var symbol: String {
        switch self {
        case .aries: "♈\u{FE0E}"
        case .taurus: "♉\u{FE0E}"
        case .gemini: "♊\u{FE0E}"
        case .cancer: "♋\u{FE0E}"
        case .leo: "♌\u{FE0E}"
        case .virgo: "♍\u{FE0E}"
        case .libra: "♎\u{FE0E}"
        case .scorpio: "♏\u{FE0E}"
        case .sagittarius: "♐\u{FE0E}"
        case .capricorn: "♑\u{FE0E}"
        case .aquarius: "♒\u{FE0E}"
        case .pisces: "♓\u{FE0E}"
        }
    }

    var displayName: String {
        rawValue.capitalized
    }

    var label: String {
        "\(symbol) \(displayName)"
    }

    private struct ZodiacRange {
        let startMonth: Int
        let startDay: Int
        let endMonth: Int
        let endDay: Int
        let sign: ZodiacSign
    }

    nonisolated static func from(month: Int, day: Int) -> ZodiacSign {
        let ranges: [ZodiacRange] = [
            .init(startMonth: 3, startDay: 21, endMonth: 4, endDay: 19, sign: .aries),
            .init(startMonth: 4, startDay: 20, endMonth: 5, endDay: 20, sign: .taurus),
            .init(startMonth: 5, startDay: 21, endMonth: 6, endDay: 20, sign: .gemini),
            .init(startMonth: 6, startDay: 21, endMonth: 7, endDay: 22, sign: .cancer),
            .init(startMonth: 7, startDay: 23, endMonth: 8, endDay: 22, sign: .leo),
            .init(startMonth: 8, startDay: 23, endMonth: 9, endDay: 22, sign: .virgo),
            .init(startMonth: 9, startDay: 23, endMonth: 10, endDay: 22, sign: .libra),
            .init(startMonth: 10, startDay: 23, endMonth: 11, endDay: 21, sign: .scorpio),
            .init(startMonth: 11, startDay: 22, endMonth: 12, endDay: 21, sign: .sagittarius),
            .init(startMonth: 12, startDay: 22, endMonth: 12, endDay: 31, sign: .capricorn),
            .init(startMonth: 1, startDay: 1, endMonth: 1, endDay: 19, sign: .capricorn),
            .init(startMonth: 1, startDay: 20, endMonth: 2, endDay: 18, sign: .aquarius),
            .init(startMonth: 2, startDay: 19, endMonth: 3, endDay: 20, sign: .pisces),
        ]
        let value = month * 100 + day
        for range in ranges {
            if value >= range.startMonth * 100 + range.startDay, value <= range.endMonth * 100 + range.endDay {
                return range.sign
            }
        }
        return .capricorn
    }
}
