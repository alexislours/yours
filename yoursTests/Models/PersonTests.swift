import Foundation
import SwiftData
import Testing
@testable import yours

@Suite("Person Model", .tags(.models))
@MainActor
struct PersonTests {
    // MARK: - Duration Description

    @Suite("Duration Description")
    @MainActor
    struct DurationDescription {
        @Test("Relationship started today shows today message")
        func today() {
            let ctx = TestSupport.makeContext()
            let person = TestSupport.seedPerson(in: ctx, relationshipStart: .now)
            #expect(person.durationDescription.contains("today"))
        }

        @Test("Days only")
        func daysOnly() {
            let ctx = TestSupport.makeContext()
            let start = Calendar.current.date(byAdding: .day, value: -5, to: .now)!
            let person = TestSupport.seedPerson(in: ctx, relationshipStart: start)
            #expect(person.durationDescription.contains("5 days"))
            #expect(!person.durationDescription.contains("month"))
            #expect(!person.durationDescription.contains("year"))
        }

        @Test("Months only")
        func monthsOnly() {
            let ctx = TestSupport.makeContext()
            let start = Calendar.current.date(
                byAdding: .month, value: -3, to: Calendar.current.startOfDay(for: .now)
            )!
            let person = TestSupport.seedPerson(in: ctx, relationshipStart: start)
            #expect(person.durationDescription.contains("3 months"))
        }

        @Test("Years only")
        func yearsOnly() {
            let ctx = TestSupport.makeContext()
            let start = Calendar.current.date(
                byAdding: .year, value: -2, to: Calendar.current.startOfDay(for: .now)
            )!
            let person = TestSupport.seedPerson(in: ctx, relationshipStart: start)
            #expect(person.durationDescription.contains("2 years"))
        }

        @Test("Mixed years, months, and days")
        func mixed() {
            let ctx = TestSupport.makeContext()
            let cal = Calendar.current
            var start = cal.date(byAdding: .year, value: -1, to: .now)!
            start = cal.date(byAdding: .month, value: -2, to: start)!
            start = cal.date(byAdding: .day, value: -10, to: start)!
            let person = TestSupport.seedPerson(in: ctx, relationshipStart: start)
            let desc = person.durationDescription
            #expect(desc.contains("1 year"))
            #expect(desc.contains("2 months"))
            #expect(desc.contains("10 days"))
        }
    }

    // MARK: - Days Until Birthday

    @Suite("Days Until Birthday")
    @MainActor
    struct DaysUntilBirthday {
        @Test("Nil when no birthday set")
        func noBirthday() {
            let ctx = TestSupport.makeContext()
            let person = TestSupport.seedPerson(in: ctx)
            #expect(person.daysUntilBirthday == nil)
        }

        @Test("Zero when birthday is today")
        func birthdayToday() {
            let ctx = TestSupport.makeContext()
            let cal = Calendar.current
            let todayComps = cal.dateComponents([.month, .day], from: .now)
            let birthday = cal.date(from: DateComponents(
                year: 1990,
                month: todayComps.month,
                day: todayComps.day
            ))!
            let person = TestSupport.seedPerson(in: ctx, birthday: birthday)
            #expect(person.daysUntilBirthday == 0)
        }

        @Test("Upcoming birthday this year")
        func upcomingThisYear() {
            let ctx = TestSupport.makeContext()
            let cal = Calendar.current
            let future = cal.date(byAdding: .day, value: 30, to: .now)!
            let futureComps = cal.dateComponents([.month, .day], from: future)
            let birthday = cal.date(from: DateComponents(
                year: 1990,
                month: futureComps.month,
                day: futureComps.day
            ))!
            let person = TestSupport.seedPerson(in: ctx, birthday: birthday)
            #expect(person.daysUntilBirthday == 30)
        }

        @Test("Birthday already passed wraps to next year")
        func passedThisYear() {
            let ctx = TestSupport.makeContext()
            let cal = Calendar.current
            let yesterday = cal.date(byAdding: .day, value: -1, to: .now)!
            let comps = cal.dateComponents([.month, .day], from: yesterday)
            let birthday = cal.date(from: DateComponents(
                year: 1990,
                month: comps.month,
                day: comps.day
            ))!
            let person = TestSupport.seedPerson(in: ctx, birthday: birthday)
            guard let days = person.daysUntilBirthday else {
                Issue.record("daysUntilBirthday should not be nil")
                return
            }
            #expect(days > 300)
        }

        @Test("Leap year birthday (Feb 29)")
        func leapYearBirthday() {
            let ctx = TestSupport.makeContext()
            let birthday = Calendar.current.date(from: DateComponents(
                year: 2000, month: 2, day: 29
            ))!
            let person = TestSupport.seedPerson(in: ctx, birthday: birthday)
            #expect(person.daysUntilBirthday != nil)
        }
    }

    // MARK: - Zodiac Sign

    @Suite("Zodiac Sign")
    @MainActor
    struct ZodiacSignTests {
        @Test("Nil when no birthday")
        func noBirthday() {
            let ctx = TestSupport.makeContext()
            let person = TestSupport.seedPerson(in: ctx)
            #expect(person.zodiacSign == nil)
        }

        @Test(
            "Resolves correct sign from birthday",
            arguments: [
                (1, 5, ZodiacSign.capricorn),
                (1, 19, ZodiacSign.capricorn),
                (1, 20, ZodiacSign.aquarius),
                (2, 18, ZodiacSign.aquarius),
                (2, 19, ZodiacSign.pisces),
                (3, 20, ZodiacSign.pisces),
                (3, 21, ZodiacSign.aries),
                (4, 19, ZodiacSign.aries),
                (4, 20, ZodiacSign.taurus),
                (5, 20, ZodiacSign.taurus),
                (5, 21, ZodiacSign.gemini),
                (6, 20, ZodiacSign.gemini),
                (6, 21, ZodiacSign.cancer),
                (7, 22, ZodiacSign.cancer),
                (7, 23, ZodiacSign.leo),
                (8, 22, ZodiacSign.leo),
                (8, 23, ZodiacSign.virgo),
                (9, 22, ZodiacSign.virgo),
                (9, 23, ZodiacSign.libra),
                (10, 22, ZodiacSign.libra),
                (10, 23, ZodiacSign.scorpio),
                (11, 21, ZodiacSign.scorpio),
                (11, 22, ZodiacSign.sagittarius),
                (12, 21, ZodiacSign.sagittarius),
                (12, 22, ZodiacSign.capricorn),
                (12, 31, ZodiacSign.capricorn),
            ] as [(Int, Int, ZodiacSign)]
        )
        func resolvesSign(month: Int, day: Int, expected: ZodiacSign) {
            let ctx = TestSupport.makeContext()
            let birthday = Calendar.current.date(from: DateComponents(
                year: 1990, month: month, day: day
            ))!
            let person = TestSupport.seedPerson(in: ctx, birthday: birthday)
            #expect(person.zodiacSign == expected)
        }

        @Test("Feb 29 resolves to Pisces")
        func feb29() {
            let ctx = TestSupport.makeContext()
            let birthday = Calendar.current.date(from: DateComponents(
                year: 2000, month: 2, day: 29
            ))!
            let person = TestSupport.seedPerson(in: ctx, birthday: birthday)
            #expect(person.zodiacSign == .pisces)
        }

        @Test("Jan 1 resolves to Capricorn")
        func jan1() {
            let ctx = TestSupport.makeContext()
            let birthday = Calendar.current.date(from: DateComponents(
                year: 1990, month: 1, day: 1
            ))!
            let person = TestSupport.seedPerson(in: ctx, birthday: birthday)
            #expect(person.zodiacSign == .capricorn)
        }
    }

    // MARK: - Sorted & Filtered Properties

    @Suite("Sorted and Filtered Properties")
    @MainActor
    struct SortedFilteredProperties {
        @Test("sortedNotes returns newest first")
        func sortedNotes() throws {
            let ctx = TestSupport.makeContext()
            let person = TestSupport.seedPerson(in: ctx)
            let note1 = TestSupport.seedNote(in: ctx, body: "First", person: person)
            note1.createdAt = TestFixtures.date(daysOffset: -2)
            let note2 = TestSupport.seedNote(in: ctx, body: "Second", person: person)
            note2.createdAt = TestFixtures.date(daysOffset: -1)
            let note3 = TestSupport.seedNote(in: ctx, body: "Third", person: person)
            note3.createdAt = TestFixtures.referenceDate
            try ctx.save()

            let sorted = person.sortedNotes
            #expect(sorted.count == 3)
            #expect(sorted[0].body == "Third")
            #expect(sorted[1].body == "Second")
            #expect(sorted[2].body == "First")
        }

        @Test("upcomingDates excludes past non-recurring dates")
        func upcomingDatesExcludesPast() {
            let ctx = TestSupport.makeContext()
            let person = TestSupport.seedPerson(in: ctx)

            TestSupport.seedImportantDate(
                in: ctx, title: "Past",
                date: TestFixtures.pastDate(daysAgo: 10),
                person: person
            )
            TestSupport.seedImportantDate(
                in: ctx, title: "Future",
                date: TestFixtures.futureDate(daysFromNow: 10),
                person: person
            )

            let upcoming = person.upcomingDates
            #expect(upcoming.count == 1)
            #expect(upcoming[0].title == "Future")
        }

        @Test("upcomingDates includes recurring dates even if base date is past")
        func upcomingDatesIncludesRecurring() {
            let ctx = TestSupport.makeContext()
            let person = TestSupport.seedPerson(in: ctx)

            TestSupport.seedImportantDate(
                in: ctx, title: "Annual",
                date: TestFixtures.pastDate(daysAgo: 30),
                recurrenceFrequency: .yearly, person: person
            )

            #expect(person.upcomingDates.count == 1)
        }

        @Test("upcomingDates sorted by nearest first")
        func upcomingDatesSorted() {
            let ctx = TestSupport.makeContext()
            let person = TestSupport.seedPerson(in: ctx)

            TestSupport.seedImportantDate(
                in: ctx, title: "Far",
                date: TestFixtures.futureDate(daysFromNow: 30),
                person: person
            )
            TestSupport.seedImportantDate(
                in: ctx, title: "Near",
                date: TestFixtures.futureDate(daysFromNow: 5),
                person: person
            )

            let upcoming = person.upcomingDates
            #expect(upcoming.count == 2)
            #expect(upcoming[0].title == "Near")
            #expect(upcoming[1].title == "Far")
        }

        @Test("activeGiftIdeas excludes archived")
        func activeGiftIdeas() {
            let ctx = TestSupport.makeContext()
            let person = TestSupport.seedPerson(in: ctx)

            TestSupport.seedGiftIdea(in: ctx, title: "Active", status: .idea, person: person)
            TestSupport.seedGiftIdea(in: ctx, title: "Purchased", status: .purchased, person: person)
            TestSupport.seedGiftIdea(in: ctx, title: "Given", status: .given, person: person)
            TestSupport.seedGiftIdea(in: ctx, title: "Archived", status: .archived, person: person)

            let active = person.activeGiftIdeas
            #expect(active.count == 3)
            #expect(!active.contains { $0.title == "Archived" })
        }

        @Test("activeAskAboutItems excludes done items")
        func activeAskAboutItems() throws {
            let ctx = TestSupport.makeContext()
            let person = TestSupport.seedPerson(in: ctx)

            TestSupport.seedAskAboutItem(in: ctx, title: "Open", person: person)
            let item2 = TestSupport.seedAskAboutItem(in: ctx, title: "Done", person: person)
            item2.isDone = true
            try ctx.save()

            let active = person.activeAskAboutItems
            #expect(active.count == 1)
            #expect(active[0].title == "Open")
        }

        @Test("likes vs dislikes split correctly")
        func likesAndDislikes() {
            let ctx = TestSupport.makeContext()
            let person = TestSupport.seedPerson(in: ctx)

            TestSupport.seedLikeDislike(in: ctx, name: "Coffee", kind: .like, person: person)
            TestSupport.seedLikeDislike(in: ctx, name: "Tea", kind: .like, person: person)
            TestSupport.seedLikeDislike(in: ctx, name: "Spiders", kind: .dislike, person: person)

            #expect(person.likes.count == 2)
            #expect(person.dislikes.count == 1)
            #expect(person.dislikes[0].name == "Spiders")
        }

        @Test("sortedQuirks returns newest first")
        func sortedQuirks() throws {
            let ctx = TestSupport.makeContext()
            let person = TestSupport.seedPerson(in: ctx)

            let q1 = TestSupport.seedQuirk(in: ctx, text: "Old", person: person)
            q1.createdAt = TestFixtures.date(daysOffset: -5)
            let q2 = TestSupport.seedQuirk(in: ctx, text: "New", person: person)
            q2.createdAt = TestFixtures.referenceDate
            try ctx.save()

            let sorted = person.sortedQuirks
            #expect(sorted.count == 2)
            #expect(sorted[0].text == "New")
            #expect(sorted[1].text == "Old")
        }
    }

    // MARK: - Count Properties

    @Suite("Count Properties")
    @MainActor
    struct CountProperties {
        @Test("importantDateCount matches total including past")
        func importantDateCount() {
            let ctx = TestSupport.makeContext()
            let person = TestSupport.seedPerson(in: ctx)

            TestSupport.seedImportantDate(
                in: ctx, title: "Past",
                date: TestFixtures.pastDate(daysAgo: 10),
                person: person
            )
            TestSupport.seedImportantDate(
                in: ctx, title: "Future",
                date: TestFixtures.futureDate(daysFromNow: 10),
                person: person
            )

            #expect(person.importantDateCount == 2)
        }

        @Test("giftIdeaCount matches active only")
        func giftIdeaCount() {
            let ctx = TestSupport.makeContext()
            let person = TestSupport.seedPerson(in: ctx)

            TestSupport.seedGiftIdea(in: ctx, title: "A", status: .idea, person: person)
            TestSupport.seedGiftIdea(in: ctx, title: "B", status: .archived, person: person)

            #expect(person.giftIdeaCount == 1)
        }

        @Test("askAboutItemCount matches active only")
        func askAboutItemCount() throws {
            let ctx = TestSupport.makeContext()
            let person = TestSupport.seedPerson(in: ctx)

            TestSupport.seedAskAboutItem(in: ctx, title: "Q1", person: person)
            let done = TestSupport.seedAskAboutItem(in: ctx, title: "Q2", person: person)
            done.isDone = true
            try ctx.save()

            #expect(person.askAboutItemCount == 1)
        }

        @Test("quirkCount matches total")
        func quirkCount() {
            let ctx = TestSupport.makeContext()
            let person = TestSupport.seedPerson(in: ctx)

            TestSupport.seedQuirk(in: ctx, text: "A", person: person)
            TestSupport.seedQuirk(in: ctx, text: "B", person: person)

            #expect(person.quirkCount == 2)
        }
    }

    // MARK: - Latest / Nearest

    @Suite("Latest and Nearest")
    @MainActor
    struct LatestNearest {
        @Test("latestNote returns most recent")
        func latestNote() throws {
            let ctx = TestSupport.makeContext()
            let person = TestSupport.seedPerson(in: ctx)

            let old = TestSupport.seedNote(in: ctx, body: "Old", person: person)
            old.createdAt = TestFixtures.date(daysOffset: -5)
            let recent = TestSupport.seedNote(in: ctx, body: "Recent", person: person)
            recent.createdAt = TestFixtures.referenceDate
            try ctx.save()

            #expect(person.latestNote?.body == "Recent")
        }

        @Test("latestNote returns nil when empty")
        func latestNoteEmpty() {
            let ctx = TestSupport.makeContext()
            let person = TestSupport.seedPerson(in: ctx)
            #expect(person.latestNote == nil)
        }

        @Test("nearestDate returns soonest upcoming")
        func nearestDate() {
            let ctx = TestSupport.makeContext()
            let person = TestSupport.seedPerson(in: ctx)

            TestSupport.seedImportantDate(
                in: ctx, title: "Far",
                date: TestFixtures.futureDate(daysFromNow: 30),
                person: person
            )
            TestSupport.seedImportantDate(
                in: ctx, title: "Near",
                date: TestFixtures.futureDate(daysFromNow: 3),
                person: person
            )

            #expect(person.nearestDate?.title == "Near")
        }

        @Test("nearestDate returns nil when no upcoming dates")
        func nearestDateEmpty() {
            let ctx = TestSupport.makeContext()
            let person = TestSupport.seedPerson(in: ctx)

            TestSupport.seedImportantDate(
                in: ctx, title: "Past",
                date: TestFixtures.pastDate(daysAgo: 10),
                person: person
            )

            #expect(person.nearestDate == nil)
        }

        @Test("latestGiftIdea returns newest active")
        func latestGiftIdea() throws {
            let ctx = TestSupport.makeContext()
            let person = TestSupport.seedPerson(in: ctx)

            let old = TestSupport.seedGiftIdea(in: ctx, title: "Old", person: person)
            old.createdAt = TestFixtures.date(daysOffset: -5)
            let archived = TestSupport.seedGiftIdea(
                in: ctx, title: "Archived", status: .archived, person: person
            )
            archived.createdAt = TestFixtures.referenceDate
            let newest = TestSupport.seedGiftIdea(in: ctx, title: "Newest", person: person)
            newest.createdAt = TestFixtures.date(daysOffset: -1)
            try ctx.save()

            #expect(person.latestGiftIdea?.title == "Newest")
        }

        @Test("latestGiftIdea returns nil when empty")
        func latestGiftIdeaEmpty() {
            let ctx = TestSupport.makeContext()
            let person = TestSupport.seedPerson(in: ctx)
            #expect(person.latestGiftIdea == nil)
        }

        @Test("latestQuirk returns most recent")
        func latestQuirk() throws {
            let ctx = TestSupport.makeContext()
            let person = TestSupport.seedPerson(in: ctx)

            let old = TestSupport.seedQuirk(in: ctx, text: "Old", person: person)
            old.createdAt = TestFixtures.date(daysOffset: -5)
            let recent = TestSupport.seedQuirk(in: ctx, text: "Recent", person: person)
            recent.createdAt = TestFixtures.referenceDate
            try ctx.save()

            #expect(person.latestQuirk?.text == "Recent")
        }

        @Test("latestQuirk returns nil when empty")
        func latestQuirkEmpty() {
            let ctx = TestSupport.makeContext()
            let person = TestSupport.seedPerson(in: ctx)
            #expect(person.latestQuirk == nil)
        }
    }

    // MARK: - Gender

    @Suite("Gender-Based String Selection")
    @MainActor
    struct GenderSelection {
        @Test("Female returns female string")
        func female() {
            let ctx = TestSupport.makeContext()
            let person = TestSupport.seedPerson(in: ctx, gender: .female)
            #expect(person.gendered(female: "her", male: "his", other: "their") == "her")
        }

        @Test("Male returns male string")
        func male() {
            let ctx = TestSupport.makeContext()
            let person = TestSupport.seedPerson(in: ctx, gender: .male)
            #expect(person.gendered(female: "her", male: "his", other: "their") == "his")
        }

        @Test("Other returns other string")
        func other() {
            let ctx = TestSupport.makeContext()
            let person = TestSupport.seedPerson(in: ctx, gender: .other)
            #expect(person.gendered(female: "her", male: "his", other: "their") == "their")
        }
    }
}
