import Foundation
import SwiftData
import Testing
@testable import yours

@Suite("AskAboutItem Model", .tags(.models, .askAboutItems))
@MainActor
struct AskAboutItemTests {
    // MARK: - Formatted Due Date

    @Suite("Formatted Due Date")
    @MainActor
    struct FormattedDueDate {
        @Test("Nil due date returns nil")
        func nilDueDate() {
            let ctx = TestSupport.makeContext()
            let person = TestSupport.seedPerson(in: ctx)
            let item = TestSupport.seedAskAboutItem(in: ctx, title: "Q", person: person)
            #expect(item.formattedDueDate == nil)
        }

        @Test("Due today shows Today")
        func dueToday() {
            let ctx = TestSupport.makeContext()
            let person = TestSupport.seedPerson(in: ctx)
            let item = TestSupport.seedAskAboutItem(
                in: ctx, title: "Q", dueDate: .now, person: person
            )
            #expect(item.formattedDueDate == "Today")
        }

        @Test("Due tomorrow shows Tomorrow")
        func dueTomorrow() {
            let ctx = TestSupport.makeContext()
            let person = TestSupport.seedPerson(in: ctx)
            let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: .now)!
            let item = TestSupport.seedAskAboutItem(
                in: ctx, title: "Q", dueDate: tomorrow, person: person
            )
            #expect(item.formattedDueDate == "Tomorrow")
        }

        @Test("Past due date shows Overdue")
        func overdue() {
            let ctx = TestSupport.makeContext()
            let person = TestSupport.seedPerson(in: ctx)
            let pastDate = TestFixtures.pastDate(daysAgo: 5)
            let item = TestSupport.seedAskAboutItem(
                in: ctx, title: "Q", dueDate: pastDate, person: person
            )
            #expect(item.formattedDueDate == "Overdue")
        }

        @Test("Future date same year shows By MMM d")
        func futureThisYear() throws {
            let ctx = TestSupport.makeContext()
            let person = TestSupport.seedPerson(in: ctx)
            let futureDate = TestFixtures.futureDate(daysFromNow: 30)
            let item = TestSupport.seedAskAboutItem(
                in: ctx, title: "Q", dueDate: futureDate, person: person
            )
            let formatted = try #require(item.formattedDueDate)
            #expect(formatted.hasPrefix("By "))
            // Same year format should not contain the year
            let yearString = String(Calendar.current.component(.year, from: .now))
            #expect(!formatted.contains(yearString))
        }

        @Test("Future date different year shows By MMM d, yyyy")
        func futureDifferentYear() throws {
            let ctx = TestSupport.makeContext()
            let person = TestSupport.seedPerson(in: ctx)
            let nextYear = try #require(Calendar.current.date(byAdding: .year, value: 1, to: .now))
            let farFuture = try #require(Calendar.current.date(byAdding: .month, value: 2, to: nextYear))
            let item = TestSupport.seedAskAboutItem(
                in: ctx, title: "Q", dueDate: farFuture, person: person
            )
            let formatted = try #require(item.formattedDueDate)
            #expect(formatted.hasPrefix("By "))
            let yearString = String(Calendar.current.component(.year, from: farFuture))
            #expect(formatted.contains(yearString))
        }
    }

    // MARK: - Is Overdue

    @Suite("Is Overdue")
    @MainActor
    struct IsOverdue {
        @Test("Not overdue when no due date")
        func noDueDate() {
            let ctx = TestSupport.makeContext()
            let person = TestSupport.seedPerson(in: ctx)
            let item = TestSupport.seedAskAboutItem(in: ctx, title: "Q", person: person)
            #expect(!item.isOverdue)
        }

        @Test("Not overdue when due date is in the future")
        func futureDueDate() {
            let ctx = TestSupport.makeContext()
            let person = TestSupport.seedPerson(in: ctx)
            let item = TestSupport.seedAskAboutItem(
                in: ctx, title: "Q",
                dueDate: TestFixtures.futureDate(daysFromNow: 5),
                person: person
            )
            #expect(!item.isOverdue)
        }

        @Test("Overdue when past due and not done")
        func pastDueNotDone() {
            let ctx = TestSupport.makeContext()
            let person = TestSupport.seedPerson(in: ctx)
            let item = TestSupport.seedAskAboutItem(
                in: ctx, title: "Q",
                dueDate: TestFixtures.pastDate(daysAgo: 3),
                person: person
            )
            #expect(item.isOverdue)
        }

        @Test("Not overdue when past due but done")
        func pastDueButDone() throws {
            let ctx = TestSupport.makeContext()
            let person = TestSupport.seedPerson(in: ctx)
            let item = TestSupport.seedAskAboutItem(
                in: ctx, title: "Q",
                dueDate: TestFixtures.pastDate(daysAgo: 3),
                person: person
            )
            item.isDone = true
            try ctx.save()
            #expect(!item.isOverdue)
        }
    }
}
