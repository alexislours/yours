import XCTest

@MainActor
final class YoursUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUp() async throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments += ["-ui_testing"]
    }

    override func tearDown() async throws {
        app = nil
    }
}
