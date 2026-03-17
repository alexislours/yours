import CloudKit
import SwiftUI

// MARK: - CloudKit Status Display

extension SettingsView {
    var cloudKitStatusLabel: String {
        switch cloudKitStatus {
        case .available: String(localized: "Active", comment: "Settings: iCloud sync status badge when syncing")
        case .noAccount: String(localized: "No Account", comment: "Settings: iCloud sync status badge when not signed in")
        case .restricted: String(localized: "Restricted", comment: "Settings: iCloud sync status badge when access restricted")
        case .temporarilyUnavailable:
            String(localized: "Unavailable", comment: "Settings: iCloud sync status badge when temporarily unavailable")
        case .couldNotDetermine: String(localized: "Unknown", comment: "Settings: iCloud sync status badge when status unknown")
        case nil: String(localized: "Checking", comment: "Settings: iCloud sync status badge while checking")
        @unknown default: String(localized: "Unknown", comment: "Settings: iCloud sync status badge when status unknown")
        }
    }

    var cloudKitStatusSubtitle: String {
        switch cloudKitStatus {
        case .available: String(localized: "Syncs across your devices", comment: "Settings: iCloud subtitle when sync is active")
        case .noAccount: String(localized: "Sign in to iCloud to sync", comment: "Settings: iCloud subtitle when not signed in")
        case .restricted: String(localized: "iCloud access is restricted", comment: "Settings: iCloud subtitle when access restricted")
        case .temporarilyUnavailable:
            String(localized: "iCloud is temporarily unavailable",
                   comment: "Settings: iCloud subtitle when temporarily unavailable")
        case .couldNotDetermine:
            String(localized: "Could not check iCloud status",
                   comment: "Settings: iCloud subtitle when status unknown")
        case nil:
            String(localized: "Checking iCloud status...",
                   comment: "Settings: iCloud subtitle while checking status")
        @unknown default:
            String(localized: "Could not check iCloud status",
                   comment: "Settings: iCloud subtitle when status unknown")
        }
    }

    var cloudKitStatusIcon: String {
        switch cloudKitStatus {
        case .available: "checkmark.icloud.fill"
        case .noAccount: "icloud.slash.fill"
        case .restricted, .temporarilyUnavailable: "exclamationmark.icloud.fill"
        case .couldNotDetermine, nil: "icloud.fill"
        @unknown default: "icloud.fill"
        }
    }

    var cloudKitStatusColor: Color {
        switch cloudKitStatus {
        case .available: Color.positive
        case .noAccount, .restricted, .temporarilyUnavailable: Color.caution
        case .couldNotDetermine, nil: Color.textTertiary
        @unknown default: Color.textTertiary
        }
    }
}
