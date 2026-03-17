import LinkPresentation
import os
import SwiftUI

struct LinkPreviewView: UIViewRepresentable {
    let url: URL

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> LPLinkView {
        let linkView = LPLinkView(url: url)
        linkView.setContentHuggingPriority(.required, for: .vertical)
        linkView.setContentCompressionResistancePriority(.required, for: .vertical)
        context.coordinator.fetchMetadata(for: url, linkView: linkView)
        return linkView
    }

    func updateUIView(_: LPLinkView, context _: Context) {}

    static func dismantleUIView(_: LPLinkView, coordinator: Coordinator) {
        coordinator.cancelFetch()
    }

    @MainActor
    final class Coordinator {
        private var fetchTask: Task<Void, Never>?

        private static let cache: NSCache<NSURL, LPLinkMetadata> = {
            let cache = NSCache<NSURL, LPLinkMetadata>()
            cache.countLimit = 50
            return cache
        }()

        func fetchMetadata(for url: URL, linkView: LPLinkView) {
            if let cached = Self.cache.object(forKey: url as NSURL) {
                linkView.metadata = cached
                return
            }

            fetchTask = Task {
                let provider = LPMetadataProvider()
                provider.timeout = 10
                do {
                    let metadata = try await provider.startFetchingMetadata(for: url)
                    guard !Task.isCancelled else { return }
                    Self.cache.setObject(metadata, forKey: url as NSURL)
                    linkView.metadata = metadata
                } catch {
                    Logger(subsystem: Bundle.main.bundleIdentifier ?? "", category: "ui")
                        .debug("Link preview metadata fetch failed for \(url): \(error)")
                }
            }
        }

        func cancelFetch() {
            fetchTask?.cancel()
            fetchTask = nil
        }
    }
}
