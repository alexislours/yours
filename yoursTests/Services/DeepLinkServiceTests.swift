import Foundation
import Testing
@testable import yours

@Suite("DeepLinkService", .tags(.services, .deepLinks))
@MainActor
struct DeepLinkServiceTests {
    @Test("yours://home resolves to .home")
    func parseHome() {
        let url = URL(string: "yours://home")!
        #expect(DeepLink(url: url) == .home)
    }

    @Test("yours://importantDates resolves to .importantDates")
    func parseImportantDates() {
        let url = URL(string: "yours://importantDates")!
        #expect(DeepLink(url: url) == .importantDates)
    }

    @Test("Unknown URLs return nil")
    func unknownURLReturnsNil() {
        let unknown = URL(string: "yours://settings")!
        #expect(DeepLink(url: unknown) == nil)

        let wrongScheme = URL(string: "other://home")!
        #expect(DeepLink(url: wrongScheme) == nil)

        let noHost = URL(string: "yours://")!
        #expect(DeepLink(url: noHost) == nil)
    }

    @Test("URL generation produces valid URLs that round-trip")
    func urlGeneration() {
        for link in [DeepLink.home, .importantDates] {
            let generated = link.url
            #expect(generated.scheme == "yours")
            #expect(DeepLink(url: generated) == link)
        }
    }
}
