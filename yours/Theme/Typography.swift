import SwiftUI

enum FontFamily {
    static let display = "Crimson Pro"
    static let ui = "Inter"
}

extension Font {
    // MARK: - Display (Crimson Pro)

    /// 48pt Light:hero moments, app name
    static let displayLarge = Font.custom(FontFamily.display, size: 48, relativeTo: .largeTitle).weight(.light)

    /// 28pt Medium:section headings
    static let heading1 = Font.custom(FontFamily.display, size: 28, relativeTo: .title).weight(.medium)

    /// 22pt Medium:card titles
    static let heading2 = Font.custom(FontFamily.display, size: 22, relativeTo: .title2).weight(.medium)

    /// 18pt Medium:list item titles, inline headings
    static let heading3 = Font.custom(FontFamily.display, size: 18, relativeTo: .title3).weight(.medium)

    // MARK: - Body (Inter)

    /// 15pt Regular:primary content, line height 1.6
    static let bodyDefault = Font.custom(FontFamily.ui, size: 15, relativeTo: .body)

    /// 13pt Regular:supporting text, line height 1.6
    static let bodySmall = Font.custom(FontFamily.ui, size: 13, relativeTo: .subheadline)

    // MARK: - Labels (Inter)

    /// 15pt Semibold:buttons, action labels
    static let label = Font.custom(FontFamily.ui, size: 15, relativeTo: .body).weight(.semibold)

    /// 11pt Semibold uppercase:section headers, +3pt tracking
    static let sectionLabel = Font.custom(FontFamily.ui, size: 11, relativeTo: .caption2).weight(.semibold)

    /// 12pt Regular:timestamps, metadata, line height 1.5
    static let caption = Font.custom(FontFamily.ui, size: 12, relativeTo: .caption)
}

// MARK: - Letter Spacing

enum LetterSpacing {
    static let displayLarge: CGFloat = -0.5
    static let display: CGFloat = -0.3
    static let sectionLabel: CGFloat = 3.0
}
