import Testing
@testable import yours

@Suite("String.nonBlank", .tags(.models, .formatting))
struct StringNonBlankTests {
    @Test("Non-empty string returns trimmed value")
    func nonEmpty() {
        #expect("hello".nonBlank == "hello")
    }

    @Test("String with leading/trailing whitespace returns trimmed")
    func trimmed() {
        #expect("  hello  ".nonBlank == "hello")
    }

    @Test("Empty string returns nil")
    func empty() {
        #expect("".nonBlank == nil)
    }

    @Test("Whitespace-only string returns nil")
    func whitespaceOnly() {
        #expect("   ".nonBlank == nil)
    }

    @Test("Newline-only string returns nil")
    func newlineOnly() {
        #expect("\n\t\n".nonBlank == nil)
    }
}
