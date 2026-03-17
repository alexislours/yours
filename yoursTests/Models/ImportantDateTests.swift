import Foundation
import SwiftData
import Testing
@testable import yours

@Suite("ImportantDate Model", .tags(.models, .importantDates))
@MainActor
struct ImportantDateTests {
    // MARK: - Next Occurrence

    @Suite("Next Occurrence")
    @MainActor
    struct NextOccurrence {
        @Test("Non-recurring returns the date itself")
        func nonRecurring() {
            let ctx = TestSupport.makeContext()
            let person = TestSupport.seedPerson(in: ctx)
            let target = TestFixtures.futureDate(daysFromNow: 20)
            let d = TestSupport.seedImportantDate(
                in: ctx, title: "One-time",
                date: target,
                person: person
            )
            #expect(Calendar.current.isDate(d.nextOccurrence, inSameDayAs: target))
        }

        @Test("Recurring date upcoming this year returns this year")
        func recurringUpcomingThisYear() {
            let ctx = TestSupport.makeContext()
            let person = TestSupport.seedPerson(in: ctx)
            let cal = Calendar.current

            // Create a date 30 days from now, but set the year in the past
            let future = cal.date(byAdding: .day, value: 30, to: .now)!
            let comps = cal.dateComponents([.month, .day], from: future)
            let pastYear = cal.date(from: DateComponents(
                year: 2000, month: comps.month, day: comps.day
            ))!

            let d = TestSupport.seedImportantDate(
                in: ctx, title: "Birthday",
                date: pastYear,
                recurrenceFrequency: .yearly, person: person
            )

            let nextComps = cal.dateComponents([.year, .month, .day], from: d.nextOccurrence)
            let currentYear = cal.component(.year, from: .now)
            #expect(nextComps.year == currentYear)
            #expect(nextComps.month == comps.month)
            #expect(nextComps.day == comps.day)
        }

        @Test("Recurring date already passed this year returns next year")
        func recurringPassedThisYear() {
            let ctx = TestSupport.makeContext()
            let person = TestSupport.seedPerson(in: ctx)
            let cal = Calendar.current

            let yesterday = cal.date(byAdding: .day, value: -1, to: .now)!
            let comps = cal.dateComponents([.month, .day], from: yesterday)
            let pastYear = cal.date(from: DateComponents(
                year: 2000, month: comps.month, day: comps.day
            ))!

            let d = TestSupport.seedImportantDate(
                in: ctx, title: "Anniversary",
                date: pastYear,
                recurrenceFrequency: .yearly, person: person
            )

            let nextComps = cal.dateComponents([.year, .month, .day], from: d.nextOccurrence)
            let nextYear = cal.component(.year, from: .now) + 1
            #expect(nextComps.year == nextYear)
            #expect(nextComps.month == comps.month)
            #expect(nextComps.day == comps.day)
        }

        @Test("Recurring date today returns today")
        func recurringToday() {
            let ctx = TestSupport.makeContext()
            let person = TestSupport.seedPerson(in: ctx)
            let cal = Calendar.current

            let todayComps = cal.dateComponents([.month, .day], from: .now)
            let pastYear = cal.date(from: DateComponents(
                year: 2000, month: todayComps.month, day: todayComps.day
            ))!

            let d = TestSupport.seedImportantDate(
                in: ctx, title: "Today recurring",
                date: pastYear,
                recurrenceFrequency: .yearly, person: person
            )

            let nextComps = cal.dateComponents([.year, .month, .day], from: d.nextOccurrence)
            let currentYear = cal.component(.year, from: .now)
            #expect(nextComps.year == currentYear)
        }
    }

    // MARK: - Days Until Next

    @Suite("Days Until Next")
    @MainActor
    struct DaysUntilNext {
        @Test("Never negative for past non-recurring date")
        func neverNegative() {
            let ctx = TestSupport.makeContext()
            let person = TestSupport.seedPerson(in: ctx)
            let d = TestSupport.seedImportantDate(
                in: ctx, title: "Past",
                date: TestFixtures.pastDate(daysAgo: 100),
                person: person
            )
            #expect(d.daysUntilNext >= 0)
        }

        @Test("Zero for today")
        func zeroForToday() {
            let ctx = TestSupport.makeContext()
            let person = TestSupport.seedPerson(in: ctx)
            let d = TestSupport.seedImportantDate(
                in: ctx, title: "Today",
                date: Calendar.current.startOfDay(for: .now),
                person: person
            )
            #expect(d.daysUntilNext == 0)
        }

        @Test("Correct count for future date")
        func futureDate() {
            let ctx = TestSupport.makeContext()
            let person = TestSupport.seedPerson(in: ctx)
            let d = TestSupport.seedImportantDate(
                in: ctx, title: "Soon",
                date: TestFixtures.futureDate(daysFromNow: 10),
                person: person
            )
            #expect(d.daysUntilNext == 10)
        }

        @Test("Never negative for recurring past date")
        func neverNegativeRecurring() {
            let ctx = TestSupport.makeContext()
            let person = TestSupport.seedPerson(in: ctx)
            let d = TestSupport.seedImportantDate(
                in: ctx, title: "Old recurring",
                date: TestFixtures.pastDate(daysAgo: 50),
                recurrenceFrequency: .yearly, person: person
            )
            #expect(d.daysUntilNext >= 0)
        }
    }

    // MARK: - isPast

    @Suite("isPast")
    @MainActor
    struct IsPast {
        @Test("True for non-recurring past date")
        func nonRecurringPast() {
            let ctx = TestSupport.makeContext()
            let person = TestSupport.seedPerson(in: ctx)
            let d = TestSupport.seedImportantDate(
                in: ctx, title: "Gone",
                date: TestFixtures.pastDate(daysAgo: 5),
                person: person
            )
            #expect(d.isPast)
        }

        @Test("False for non-recurring future date")
        func nonRecurringFuture() {
            let ctx = TestSupport.makeContext()
            let person = TestSupport.seedPerson(in: ctx)
            let d = TestSupport.seedImportantDate(
                in: ctx, title: "Coming",
                date: TestFixtures.futureDate(daysFromNow: 5),
                person: person
            )
            #expect(!d.isPast)
        }

        @Test("False for recurring even when base date is past")
        func recurringNeverPast() {
            let ctx = TestSupport.makeContext()
            let person = TestSupport.seedPerson(in: ctx)
            let d = TestSupport.seedImportantDate(
                in: ctx, title: "Annual",
                date: TestFixtures.pastDate(daysAgo: 365),
                recurrenceFrequency: .yearly, person: person
            )
            #expect(!d.isPast)
        }

        @Test("False for today")
        func todayNotPast() {
            let ctx = TestSupport.makeContext()
            let person = TestSupport.seedPerson(in: ctx)
            let d = TestSupport.seedImportantDate(
                in: ctx, title: "Today",
                date: Calendar.current.startOfDay(for: .now),
                person: person
            )
            #expect(!d.isPast)
        }
    }

    // MARK: - Countdown Text

    @Suite("Countdown Text")
    @MainActor
    struct CountdownText {
        @Test("Shows Today for event today")
        func today() {
            let ctx = TestSupport.makeContext()
            let person = TestSupport.seedPerson(in: ctx)
            let d = TestSupport.seedImportantDate(
                in: ctx, title: "Now",
                date: Calendar.current.startOfDay(for: .now),
                person: person
            )
            #expect(d.countdownText == "Today")
        }

        @Test("Shows Tomorrow for event tomorrow")
        func tomorrow() {
            let ctx = TestSupport.makeContext()
            let person = TestSupport.seedPerson(in: ctx)
            let d = TestSupport.seedImportantDate(
                in: ctx, title: "Soon",
                date: TestFixtures.futureDate(daysFromNow: 1),
                person: person
            )
            #expect(d.countdownText == "Tomorrow")
        }

        @Test("Shows in X days for future event")
        func inXDays() {
            let ctx = TestSupport.makeContext()
            let person = TestSupport.seedPerson(in: ctx)
            let d = TestSupport.seedImportantDate(
                in: ctx, title: "Later",
                date: TestFixtures.futureDate(daysFromNow: 7),
                person: person
            )
            #expect(d.countdownText == "in 7 days")
        }
    }

    // MARK: - Days Since Text

    @Suite("Days Since Text")
    @MainActor
    struct DaysSinceText {
        @Test("Nil for future date")
        func nilForFuture() {
            let ctx = TestSupport.makeContext()
            let person = TestSupport.seedPerson(in: ctx)
            let d = TestSupport.seedImportantDate(
                in: ctx, title: "Future",
                date: TestFixtures.futureDate(daysFromNow: 5),
                person: person
            )
            #expect(d.daysSinceText == nil)
        }

        @Test("Nil for recurring date")
        func nilForRecurring() {
            let ctx = TestSupport.makeContext()
            let person = TestSupport.seedPerson(in: ctx)
            let d = TestSupport.seedImportantDate(
                in: ctx, title: "Recurring past",
                date: TestFixtures.pastDate(daysAgo: 10),
                recurrenceFrequency: .yearly, person: person
            )
            #expect(d.daysSinceText == nil)
        }

        @Test("Shows 1 day ago for yesterday")
        func oneDayAgo() {
            let ctx = TestSupport.makeContext()
            let person = TestSupport.seedPerson(in: ctx)
            let d = TestSupport.seedImportantDate(
                in: ctx, title: "Yesterday",
                date: TestFixtures.pastDate(daysAgo: 1),
                person: person
            )
            #expect(d.daysSinceText == "1 day ago")
        }

        @Test("Shows X days ago for past date")
        func xDaysAgo() {
            let ctx = TestSupport.makeContext()
            let person = TestSupport.seedPerson(in: ctx)
            let d = TestSupport.seedImportantDate(
                in: ctx, title: "Old",
                date: TestFixtures.pastDate(daysAgo: 10),
                person: person
            )
            #expect(d.daysSinceText == "10 days ago")
        }
    }

    // MARK: - Formatted Date

    @Suite("Formatted Date")
    @MainActor
    struct FormattedDate {
        @Test("Non-recurring uses the original date")
        func nonRecurring() {
            let ctx = TestSupport.makeContext()
            let person = TestSupport.seedPerson(in: ctx)
            let target = TestFixtures.futureDate(daysFromNow: 15)
            let d = TestSupport.seedImportantDate(
                in: ctx, title: "One-off",
                date: target,
                person: person
            )
            let expected = target.formatted(.dateTime.month(.wide).day().year())
            #expect(d.formattedDate == expected)
        }

        @Test("Recurring uses next occurrence year")
        func recurringUsesNextOccurrence() {
            let ctx = TestSupport.makeContext()
            let person = TestSupport.seedPerson(in: ctx)
            let cal = Calendar.current

            // Use a date 30 days from now but set in the past
            let future = cal.date(byAdding: .day, value: 30, to: .now)!
            let comps = cal.dateComponents([.month, .day], from: future)
            let pastYear = cal.date(from: DateComponents(
                year: 2000, month: comps.month, day: comps.day
            ))!

            let d = TestSupport.seedImportantDate(
                in: ctx, title: "Recurring",
                date: pastYear,
                recurrenceFrequency: .yearly, person: person
            )

            let expected = d.nextOccurrence.formatted(.dateTime.month(.wide).day().year())
            #expect(d.formattedDate == expected)
            #expect(d.formattedDate.contains(String(cal.component(.year, from: .now))))
        }
    }
}
