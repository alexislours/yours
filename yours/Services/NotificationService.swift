import Foundation
import os
import SwiftData
import UserNotifications

// MARK: - NotificationScheduling Protocol

@MainActor
protocol NotificationScheduling {
    func addRequest(_ request: UNNotificationRequest)
    func removeRequests(withIdentifiers identifiers: [String])
    func removeAllRequests()
}

@MainActor
final class LiveNotificationScheduler: NotificationScheduling {
    func addRequest(_ request: UNNotificationRequest) {
        UNUserNotificationCenter.current().add(request)
    }

    func removeRequests(withIdentifiers identifiers: [String]) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    func removeAllRequests() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}

// MARK: - NotificationService

@MainActor
final class NotificationService {
    static let shared = NotificationService()

    private let scheduler: any NotificationScheduling

    private init() {
        scheduler = LiveNotificationScheduler()
    }

    init(scheduler: any NotificationScheduling) {
        self.scheduler = scheduler
    }

    // MARK: - Permission

    func requestPermission() async -> Bool {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()

        switch settings.authorizationStatus {
        case .authorized, .provisional:
            return true
        case .notDetermined:
            return await (try? center.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
        default:
            return false
        }
    }

    // MARK: - Scheduling

    /// Reschedules all notifications for every important date that has reminders enabled.
    func rescheduleAll(modelContext: ModelContext) {
        scheduler.removeAllRequests()

        guard UserDefaults.standard.bool(forKey: UserDefaultsKeys.notificationsEnabled) else { return }

        let hour = UserDefaults.standard.integer(forKey: UserDefaultsKeys.notificationHour)
        let minute = UserDefaults.standard.integer(forKey: UserDefaultsKeys.notificationMinute)
        let notifHour = (hour == 0 && !UserDefaults.standard.bool(forKey: UserDefaultsKeys.notificationTimeSet)) ? 9 : hour
        let notifMinute = (hour == 0 && !UserDefaults.standard.bool(forKey: UserDefaultsKeys.notificationTimeSet)) ? 0 : minute

        let descriptor = FetchDescriptor<ImportantDate>()
        let dates: [ImportantDate]
        do {
            dates = try modelContext.fetch(descriptor)
        } catch {
            Logger(subsystem: Bundle.main.bundleIdentifier ?? "", category: "notifications")
                .error("Failed to fetch important dates for rescheduling: \(error)")
            return
        }

        for importantDate in dates where importantDate.reminderEnabled {
            scheduleNotification(for: importantDate, hour: notifHour, minute: notifMinute)
        }
    }

    /// Schedule a single notification for an important date.
    func scheduleNotification(for importantDate: ImportantDate, hour: Int, minute: Int) {
        let identifier = notificationIdentifier(for: importantDate)

        scheduler.removeRequests(withIdentifiers: [identifier])

        guard importantDate.reminderEnabled else { return }

        let targetDate = importantDate.nextOccurrence
        let calendar = Calendar.current

        guard let reminderDate = calendar.date(
            byAdding: .day,
            value: -importantDate.reminderDaysBefore,
            to: targetDate
        ) else { return }

        var components = calendar.dateComponents([.year, .month, .day], from: reminderDate)
        components.hour = hour
        components.minute = minute

        // Don't schedule if the reminder date is in the past
        if let fireDate = calendar.date(from: components), fireDate <= .now {
            return
        }

        let content = UNMutableNotificationContent()
        content.title = importantDate.title
        content.sound = .default

        let daysBefore = importantDate.reminderDaysBefore
        if daysBefore == 0 {
            content.body = String(localized: "Today is the day!", comment: "Notification: event is today")
        } else if daysBefore == 1 {
            content.body = String(localized: "Tomorrow!", comment: "Notification: event is tomorrow")
        } else {
            content.body = String(localized: "Coming up in \(daysBefore) days.", comment: "Notification: days until event")
        }

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        scheduler.addRequest(request)
    }

    /// Remove the notification for a specific important date.
    func removeNotification(for importantDate: ImportantDate) {
        scheduler.removeRequests(withIdentifiers: [notificationIdentifier(for: importantDate)])
    }

    // MARK: - Helpers

    private func notificationIdentifier(for importantDate: ImportantDate) -> String {
        "importantDate-\(importantDate.persistentModelID)"
    }
}
