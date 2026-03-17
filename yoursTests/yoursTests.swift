import Testing
@testable import yours

// Test files go in subdirectories by domain (e.g. Models/, Services/).
// This file exists only to verify the test target builds and imports correctly.

@Suite("Yours Tests")
struct YoursTests {
    @Test func testTargetBuilds() {
        // Intentionally empty: validates the test target links against the app.
    }
}
