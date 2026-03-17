import XCTest

@MainActor
final class ScreenshotTests: XCTestCase, @unchecked Sendable {
    var app: XCUIApplication!

    override nonisolated func setUpWithError() throws {
        MainActor.assumeIsolated {
            continueAfterFailure = false
            app = XCUIApplication()
            setupSnapshot(app, waitForAnimations: false)
        }
    }

    // MARK: - Per-Language Test Entry Points

    func testScreenshots_EnUS() {
        runScreenshots(language: "en-US", locale: "en_US")
    }

    // MARK: - Shared Runner

    private func runScreenshots(language: String, locale: String) {
        MainActor.assumeIsolated {
            Snapshot.deviceLanguage = language
            Snapshot.currentLocale = locale
        }

        app.launchArguments = [
            "--screenshots",
            "-AppleLanguages", "(\(language))",
            "-AppleLocale", locale,
            "-FASTLANE_SNAPSHOT", "YES",
            "-ui_testing",
        ]

        captureOnboardingIntro()

        // --screenshots flag seeds mock data on launch
        app.launch()

        let importantDatesCard = app.buttons["card-important-dates"].firstMatch
        XCTAssertTrue(
            importantDatesCard.waitForExistence(timeout: 15),
            "[02-Home] 'card-important-dates' not found after relaunch. App hierarchy:\n\(app.debugDescription)"
        )

        XCUIDevice.shared.appearance = .light
        sleep(1)
        snap("02-Home")

        captureAboutView()
        captureGiftIdeas()
        captureImportantDates()
        captureDateFormSheet()
        captureDarkModeHome()
    }

    // MARK: - 01 Onboarding Intro

    private func captureOnboardingIntro() {
        XCUIDevice.shared.appearance = .light
        // Launch without --screenshots so no mock data is seeded and onboarding appears naturally
        let savedArgs = app.launchArguments
        app.launchArguments = savedArgs.filter { $0 != "--screenshots" }
        app.launch()
        app.launchArguments = savedArgs

        let introView = app.descendants(matching: .any)["view-onboarding-intro"].firstMatch
        XCTAssertTrue(
            introView.waitForExistence(timeout: 10),
            "[01-Onboarding] 'view-onboarding-intro' not found. App hierarchy:\n\(app.debugDescription)"
        )
        sleep(1) // Wait for entrance animation
        snap("01-OnboardingIntro")

        app.terminate()
    }

    // MARK: - 03 About View

    private func captureAboutView() {
        let aboutCard = app.buttons["card-about"].firstMatch
        XCTAssertTrue(
            aboutCard.waitForExistence(timeout: 5),
            "[03-About] 'card-about' not found on Home. App hierarchy:\n\(app.debugDescription)"
        )
        aboutCard.tap()

        let birthdayLabel = app.staticTexts["BIRTHDAY"].firstMatch
        XCTAssertTrue(
            birthdayLabel.waitForExistence(timeout: 10),
            "[03-About] 'BIRTHDAY' label not found after tapping About card. App hierarchy:\n\(app.debugDescription)"
        )
        sleep(1)
        snap("03-About")

        tapBackButton()
    }

    // MARK: - 04 Gift Ideas

    private func captureGiftIdeas() {
        let giftCard = app.buttons["card-gift-ideas"].firstMatch
        XCTAssertTrue(
            giftCard.waitForExistence(timeout: 5),
            "[04-GiftIdeas] 'card-gift-ideas' not found on Home. App hierarchy:\n\(app.debugDescription)"
        )
        giftCard.tap()

        let searchBar = app.textFields.firstMatch
        XCTAssertTrue(
            searchBar.waitForExistence(timeout: 10),
            "[04-GiftIdeas] Search bar (textField) not found after tapping Gift Ideas card. App hierarchy:\n\(app.debugDescription)"
        )
        sleep(1)
        snap("04-GiftIdeas")

        tapBackButton()
    }

    // MARK: - 05 Important Dates

    private func captureImportantDates() {
        let datesCard = app.buttons["card-important-dates"].firstMatch
        XCTAssertTrue(
            datesCard.waitForExistence(timeout: 5),
            "[05-ImportantDates] 'card-important-dates' not found on Home. App hierarchy:\n\(app.debugDescription)"
        )
        datesCard.tap()

        let searchBar = app.textFields.firstMatch
        XCTAssertTrue(
            searchBar.waitForExistence(timeout: 10),
            "[05-ImportantDates] Search bar (textField) not found after tapping Important Dates card. App hierarchy:\n\(app.debugDescription)"
        )
        sleep(1)
        snap("05-ImportantDates")
    }

    // MARK: - 06 Date Form Sheet

    private func captureDateFormSheet() {
        let fab = app.buttons["fab-add-date"].firstMatch
        XCTAssertTrue(
            fab.waitForExistence(timeout: 5),
            "[06-AddDate] 'fab-add-date' not found on Important Dates. App hierarchy:\n\(app.debugDescription)"
        )
        fab.tap()

        let formSheet = app.otherElements["sheet-date-form"].firstMatch
        XCTAssertTrue(
            formSheet.waitForExistence(timeout: 5),
            "[06-AddDate] 'sheet-date-form' not found after tapping FAB. App hierarchy:\n\(app.debugDescription)"
        )

        let titleField = app.textFields["field-date-title"].firstMatch
        XCTAssertTrue(
            titleField.waitForExistence(timeout: 5),
            "[06-AddDate] Title text field not found in form sheet. App hierarchy:\n\(app.debugDescription)"
        )
        titleField.tap()
        titleField.typeText("Date night")
        titleField.typeText("\n")
        sleep(1)

        let recurringSwitch = app.switches.firstMatch
        if recurringSwitch.waitForExistence(timeout: 3) {
            recurringSwitch.tap()
        }

        sleep(1)

        formSheet.swipeDown() // scroll to top before capturing
        sleep(1)
        snap("06-AddDate")

        let dismissButton = app.buttons["btn-back"].firstMatch
        XCTAssertTrue(
            dismissButton.waitForExistence(timeout: 3),
            "[06-AddDate] 'btn-back' not found to dismiss form sheet. App hierarchy:\n\(app.debugDescription)"
        )
        dismissButton.tap()
        sleep(2)

        tapBackButton()
    }

    // MARK: - 07 Dark Mode Home

    private func captureDarkModeHome() {
        // Relaunch so the entire UI renders dark from the start — setting appearance mid-run is unreliable
        XCUIDevice.shared.appearance = .dark
        app.launch()

        let importantDatesCard = app.buttons["card-important-dates"].firstMatch
        XCTAssertTrue(
            importantDatesCard.waitForExistence(timeout: 15),
            "[07-DarkHome] 'card-important-dates' not found after dark-mode relaunch. App hierarchy:\n\(app.debugDescription)"
        )
        sleep(1)
        snap("07-DarkHome")

        XCUIDevice.shared.appearance = .light
    }

    // MARK: - Helpers

    private func snap(_ name: String) {
        snapshot(name, timeWaitingForIdle: 0)
    }

    private func tapBackButton(caller: String = #function) {
        let backButton = app.buttons["btn-back"].firstMatch
        XCTAssertTrue(
            backButton.waitForExistence(timeout: 3),
            "[\(caller)] 'btn-back' not found for navigation back. App hierarchy:\n\(app.debugDescription)"
        )
        backButton.tap()

        let homeCard = app.buttons["card-important-dates"].firstMatch
        XCTAssertTrue(
            homeCard.waitForExistence(timeout: 5),
            "[\(caller)] 'card-important-dates' not found after tapping back - did not return to Home. App hierarchy:\n\(app.debugDescription)"
        )
    }
}
