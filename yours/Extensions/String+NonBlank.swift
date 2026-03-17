import Foundation

extension String {
    /// Returns the whitespace-trimmed string if non-empty, or `nil` if blank.
    var nonBlank: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
