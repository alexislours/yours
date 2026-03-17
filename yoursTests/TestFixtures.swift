import Foundation
@testable import yours

enum TestFixtures {
    // MARK: - Reference Dates

    /// Fixed reference date: 2026-01-15 10:00:00 UTC
    static let referenceDate: Date = {
        var comps = DateComponents()
        comps.year = 2026
        comps.month = 1
        comps.day = 15
        comps.hour = 10
        comps.minute = 0
        comps.second = 0
        comps.timeZone = TimeZone(identifier: "UTC")
        return Calendar.current.date(from: comps)!
    }()

    /// Returns a date offset by `days` from `referenceDate`.
    static func date(daysOffset days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: days, to: referenceDate)!
    }

    /// Returns a date at a specific hour on a given day offset.
    static func date(daysOffset days: Int, hour: Int, minute: Int = 0) -> Date {
        let cal = Calendar.current
        var comps = DateComponents()
        comps.year = 2026
        comps.month = 1
        comps.day = 15 + days
        comps.hour = hour
        comps.minute = minute
        comps.second = 0
        comps.timeZone = cal.timeZone
        return cal.date(from: comps)!
    }

    /// A birthday in the past (1995-03-15).
    static let sampleBirthday: Date = {
        var comps = DateComponents()
        comps.year = 1995
        comps.month = 3
        comps.day = 15
        comps.timeZone = TimeZone(identifier: "UTC")
        return Calendar.current.date(from: comps)!
    }()

    /// A relationship start date (2025-06-01).
    static let sampleRelationshipStart: Date = {
        var comps = DateComponents()
        comps.year = 2025
        comps.month = 6
        comps.day = 1
        comps.timeZone = TimeZone(identifier: "UTC")
        return Calendar.current.date(from: comps)!
    }()

    // MARK: - Date Helpers

    /// Creates an array of dates representing `count` consecutive days starting from `referenceDate`.
    static func consecutiveDays(count: Int) -> [Date] {
        (0 ..< count).map { date(daysOffset: $0) }
    }

    /// Returns a future date relative to today, useful for testing upcoming date logic.
    static func futureDate(daysFromNow days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: days, to: Calendar.current.startOfDay(for: .now))!
    }

    /// Returns a past date relative to today, useful for testing past date logic.
    static func pastDate(daysAgo days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: -days, to: Calendar.current.startOfDay(for: .now))!
    }
}
