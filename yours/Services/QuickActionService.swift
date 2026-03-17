import UIKit

// MARK: - Quick Action Types

enum QuickAction: String {
    case addNote = "com.yours.addNote"
    case addGiftIdea = "com.yours.addGiftIdea"
}

// MARK: - Notification

extension Notification.Name {
    static let quickActionTriggered = Notification.Name("com.yours.quickAction")
}

// MARK: - Shortcut Registration Protocol

@MainActor
protocol ShortcutRegistering {
    func setShortcutItems(_ items: [UIApplicationShortcutItem]?)
}

extension UIApplication: ShortcutRegistering {
    func setShortcutItems(_ items: [UIApplicationShortcutItem]?) {
        shortcutItems = items
    }
}

// MARK: - Registration

enum QuickActionService {
    @MainActor
    static func registerShortcuts(using registrar: some ShortcutRegistering = UIApplication.shared) {
        registrar.setShortcutItems([
            UIApplicationShortcutItem(
                type: QuickAction.addNote.rawValue,
                localizedTitle: String(localized: "Add a Note", comment: "Quick action: add a note"),
                localizedSubtitle: nil,
                icon: UIApplicationShortcutIcon(systemImageName: "note.text")
            ),
            UIApplicationShortcutItem(
                type: QuickAction.addGiftIdea.rawValue,
                localizedTitle: String(localized: "Add a Gift Idea", comment: "Quick action: add a gift idea"),
                localizedSubtitle: nil,
                icon: UIApplicationShortcutIcon(systemImageName: "gift")
            ),
        ])
    }

    @MainActor
    static func clearShortcuts(using registrar: some ShortcutRegistering = UIApplication.shared) {
        registrar.setShortcutItems([])
    }
}
