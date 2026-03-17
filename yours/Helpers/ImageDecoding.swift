import SwiftUI
import UIKit

/// Decodes raw image data into a SwiftUI `Image` off the main actor.
nonisolated func decodeImage(from data: Data) async -> Image? {
    await Task.detached {
        UIImage(data: data).map { Image(uiImage: $0) }
    }.value
}
