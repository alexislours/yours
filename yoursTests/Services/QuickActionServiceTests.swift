import Testing
import UIKit
@testable import yours

// MARK: - Mock

@MainActor
final class MockShortcutRegistrar: ShortcutRegistering {
    var items: [UIApplicationShortcutItem]?

    func setShortcutItems(_ items: [UIApplicationShortcutItem]?) {
        self.items = items
    }
}

// MARK: - Tests

@Suite("QuickActionService", .tags(.services, .quickActions))
@MainActor
struct QuickActionServiceTests {
    @Test("Registering shortcuts creates the expected shortcut items")
    func registerShortcuts() {
        let mock = MockShortcutRegistrar()
        QuickActionService.registerShortcuts(using: mock)

        let items = mock.items ?? []
        #expect(items.count == 2)
        #expect(items[0].type == QuickAction.addNote.rawValue)
        #expect(items[0].localizedTitle == String(localized: "Add a Note", comment: "Quick action: add a note"))
        #expect(items[1].type == QuickAction.addGiftIdea.rawValue)
        #expect(items[1].localizedTitle == String(localized: "Add a Gift Idea", comment: "Quick action: add a gift idea"))
    }

    @Test("Clearing shortcuts removes all items")
    func clearShortcuts() {
        let mock = MockShortcutRegistrar()
        QuickActionService.registerShortcuts(using: mock)
        QuickActionService.clearShortcuts(using: mock)

        let items = mock.items ?? []
        #expect(items.isEmpty)
    }

    @Test("QuickAction raw values match expected bundle identifiers")
    func quickActionRawValues() {
        #expect(QuickAction.addNote.rawValue == "com.yours.addNote")
        #expect(QuickAction.addGiftIdea.rawValue == "com.yours.addGiftIdea")
    }
}
