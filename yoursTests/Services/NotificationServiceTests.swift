import Foundation
import SwiftData
import Testing
import UserNotifications
@testable import yours

// MARK: - Mock

@MainActor
final class MockNotificationScheduler: NotificationScheduling {
    var addedRequests: [UNNotificationRequest] = []
    var removedIdentifiers: [[String]] = []
    var removeAllCallCount = 0

    func addRequest(_ request: UNNotificationRequest) {
        addedRequests.append(request)
    }

    func removeRequests(withIdentifiers identifiers: [String]) {
        removedIdentifiers.append(identifiers)
    }

    func removeAllRequests() {
        removeAllCallCount += 1
    }
}

// MARK: - Tests

@Suite("NotificationService", .tags(.services, .notifications), .serialized)
@MainActor
struct NotificationServiceTests {
    private static let userDefaultsKeys = [
        UserDefaultsKeys.notificationsEnabled,
        UserDefaultsKeys.notificationHour,
        UserDefaultsKeys.notificationMinute,
        UserDefaultsKeys.notificationTimeSet,
    ]

    init() {
        for key in Self.userDefaultsKeys {
            UserDefaults.standard.removeObject(forKey: key)
        }
    }

    @Test("Scheduling uses the correct calendar date offset by reminder days")
    func schedulingUsesCorrectDate() throws {
        let ctx = TestSupport.makeContext()
        let person = TestSupport.seedPerson(in: ctx)
        let mock = MockNotificationScheduler()
        let service = NotificationService(scheduler: mock)

        let eventDate = TestFixtures.futureDate(daysFromNow: 30)
        let date = TestSupport.seedImportantDate(
            in: ctx, title: "Test Event",
            date: eventDate,
            reminderEnabled: true,
            reminderDaysBefore: 3,
            person: person
        )

        service.scheduleNotification(for: date, hour: 9, minute: 30)

        #expect(mock.addedRequests.count == 1)
        let trigger = try #require(mock.addedRequests[0].trigger as? UNCalendarNotificationTrigger)
        let comps = trigger.dateComponents

        let cal = Calendar.current
        let expectedReminderDate = cal.date(byAdding: .day, value: -3, to: eventDate)!
        let expected = cal.dateComponents([.year, .month, .day], from: expectedReminderDate)

        #expect(comps.year == expected.year)
        #expect(comps.month == expected.month)
        #expect(comps.day == expected.day)
        #expect(comps.hour == 9)
        #expect(comps.minute == 30)
    }

    @Test("Rescheduling removes all existing notifications before creating new ones")
    func reschedulingRemovesAll() {
        let ctx = TestSupport.makeContext()
        let person = TestSupport.seedPerson(in: ctx)
        let mock = MockNotificationScheduler()
        let service = NotificationService(scheduler: mock)

        UserDefaults.standard.set(true, forKey: UserDefaultsKeys.notificationsEnabled)
        UserDefaults.standard.set(true, forKey: UserDefaultsKeys.notificationTimeSet)
        UserDefaults.standard.set(9, forKey: UserDefaultsKeys.notificationHour)
        UserDefaults.standard.set(0, forKey: UserDefaultsKeys.notificationMinute)

        TestSupport.seedImportantDate(
            in: ctx, title: "Birthday",
            date: TestFixtures.futureDate(daysFromNow: 30),
            reminderEnabled: true,
            reminderDaysBefore: 1,
            person: person
        )

        service.rescheduleAll(modelContext: ctx)

        #expect(mock.removeAllCallCount == 1)
        #expect(mock.addedRequests.count == 1)
    }

    @Test("Only dates with reminders enabled get notifications")
    func onlyEnabledReminders() {
        let ctx = TestSupport.makeContext()
        let person = TestSupport.seedPerson(in: ctx)
        let mock = MockNotificationScheduler()
        let service = NotificationService(scheduler: mock)

        UserDefaults.standard.set(true, forKey: UserDefaultsKeys.notificationsEnabled)
        UserDefaults.standard.set(true, forKey: UserDefaultsKeys.notificationTimeSet)
        UserDefaults.standard.set(9, forKey: UserDefaultsKeys.notificationHour)
        UserDefaults.standard.set(0, forKey: UserDefaultsKeys.notificationMinute)

        TestSupport.seedImportantDate(
            in: ctx, title: "With Reminder",
            date: TestFixtures.futureDate(daysFromNow: 30),
            reminderEnabled: true,
            reminderDaysBefore: 1,
            person: person
        )
        TestSupport.seedImportantDate(
            in: ctx, title: "No Reminder",
            date: TestFixtures.futureDate(daysFromNow: 60),
            reminderEnabled: false,
            person: person
        )

        service.rescheduleAll(modelContext: ctx)

        #expect(mock.addedRequests.count == 1)
        #expect(mock.addedRequests[0].content.title == "With Reminder")
    }

    @Test("Removing a notification uses the correct identifier")
    func removeUsesCorrectIdentifier() {
        let ctx = TestSupport.makeContext()
        let person = TestSupport.seedPerson(in: ctx)
        let mock = MockNotificationScheduler()
        let service = NotificationService(scheduler: mock)

        let date = TestSupport.seedImportantDate(
            in: ctx, title: "Test",
            date: TestFixtures.futureDate(daysFromNow: 30),
            person: person
        )

        service.removeNotification(for: date)

        #expect(mock.removedIdentifiers.count == 1)
        let expectedId = "importantDate-\(date.persistentModelID)"
        #expect(mock.removedIdentifiers[0] == [expectedId])
    }
}
