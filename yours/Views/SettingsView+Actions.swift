import SwiftData
import SwiftUI
import UserNotifications

// MARK: - Settings Actions

extension SettingsView {
    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }

    func handleVersionTap() {
        versionTapCount += 1

        if devModeEnabled {
            return
        }

        if versionTapCount >= 5 {
            versionTapCount = 0
            devModeEnabled = true
            showDevModeToast = true
            HapticFeedback.fire(.success)
        }
    }

    func sendTestNotification() {
        Task {
            let granted = await NotificationService.shared.requestPermission()
            guard granted else { return }

            let content = UNMutableNotificationContent()
            content.title = "Yours"
            content.body = "This is a test notification. Reminders are working!"
            content.sound = .default

            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
            let request = UNNotificationRequest(identifier: "test-notification", content: content, trigger: trigger)
            try? await UNUserNotificationCenter.current().add(request)
        }
    }

    func resetPostOnboarding() {
        guard let person = persons.first else { return }
        person.birthday = nil
        deleteAll(person.notes ?? [])
        deleteAll(person.importantDates ?? [])
        deleteAll(person.giftIdeas ?? [])
        deleteAll(person.likeDislikeItems ?? [])
        deleteAll(person.askAboutItems ?? [])
        deleteAll(person.clothingSizeItems ?? [])
        deleteAll(person.allergyItems ?? [])
        deleteAll(person.foodOrderItems ?? [])
        deleteAll(person.quirks ?? [])
        deleteAll(person.theirPeopleItems ?? [])
        dismiss()
    }

    func deleteAll(_ items: [some PersistentModel]) {
        for item in items {
            modelContext.delete(item)
        }
    }

    func prepareExport() {
        guard let person = persons.first else { return }
        do {
            let result = try DataExportImportService.export(person: person)
            shareFile = ShareFile(url: result.fileURL)
        } catch {
            showError(error.localizedDescription)
        }
    }

    func handleImport(result: Result<URL, Error>) {
        guard case let .success(url) = result,
              let person = persons.first
        else { return }

        do {
            try DataExportImportService.importData(from: url, into: person, modelContext: modelContext)
            showImportSuccess = true
        } catch {
            showError(error.localizedDescription)
        }
    }

    func showError(_ message: String) {
        importError = message
        showImportError = true
    }

    func startOver() {
        for person in persons {
            modelContext.delete(person)
        }
    }
}
