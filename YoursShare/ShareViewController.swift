import SwiftUI
import UIKit
import UniformTypeIdentifiers

@objc(ShareViewController)
final class ShareViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear

        Task { @MainActor in
            let (url, title) = await extractSharedContent()

            let formView = ShareFormView(
                initialURL: url ?? "",
                initialTitle: title ?? "",
                onSave: { [weak self] in self?.close() },
                onCancel: { [weak self] in self?.cancel() }
            )

            let hostingController = UIHostingController(rootView: formView)
            hostingController.view.backgroundColor = .clear
            addChild(hostingController)
            view.addSubview(hostingController.view)
            hostingController.view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
                hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            ])
            hostingController.didMove(toParent: self)
        }
    }

    private func extractSharedContent() async -> (url: String?, title: String?) {
        guard let items = extensionContext?.inputItems as? [NSExtensionItem] else {
            return (nil, nil)
        }

        var sharedURL: String?
        var sharedTitle: String?

        for item in items {
            if sharedTitle == nil,
               let content = item.attributedContentText?.string,
               !content.isEmpty {
                sharedTitle = content
            }

            guard let attachments = item.attachments else { continue }
            for provider in attachments
                where provider.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
                if let loadedItem = try? await provider.loadItem(
                    forTypeIdentifier: UTType.url.identifier
                ),
                    let url = loadedItem as? URL {
                    sharedURL = url.absoluteString
                }
            }
        }

        return (sharedURL, sharedTitle)
    }

    private func close() {
        extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }

    private func cancel() {
        extensionContext?.cancelRequest(withError: NSError(
            domain: NSCocoaErrorDomain,
            code: NSUserCancelledError
        ))
    }
}
