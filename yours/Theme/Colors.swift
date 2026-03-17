import SwiftUI

// MARK: - Semantic Color Tokens

// periphery:ignore
/// Namespaced color tokens to avoid conflicts with asset catalog auto-generation.
/// Usage: .foregroundStyle(AppColor.textPrimary)
enum AppColor {
    // Backgrounds
    static let bgPrimary = Color(.bgPrimary)
    static let bgSubtle = Color(.bgSubtle)
    static let bgSurface = Color(.bgSurface)
    static let bgSurfaceWarm = Color(.bgSurfaceWarm)
    static let bgMuted = Color(.bgMuted)

    // Text
    static let textPrimary = Color(.textPrimary)
    static let textSecondary = Color(.textSecondary)
    static let textTertiary = Color(.textTertiary)
    static let textDisabled = Color(.textDisabled)
    static let textOnAccent = Color(.textOnAccent)

    // Accents
    static let accentPrimary = Color(.accentPrimary)
    static let accentPrimarySoft = Color(.accentPrimarySoft)
    static let accentSecondary = Color(.accentSecondary)
    static let accentSecondarySoft = Color(.accentSecondarySoft)
    static let accentRose = Color(.accentRose)
    static let accentRoseSoft = Color(.accentRoseSoft)

    // Borders
    static let borderSubtle = Color(.borderSubtle)
    static let borderDefault = Color(.borderDefault)
    static let borderStrong = Color(.borderStrong)

    // Semantic
    static let positive = Color(.positive)
    static let positiveSoft = Color(.positiveSoft)
    static let caution = Color(.caution)
    static let cautionSoft = Color(.cautionSoft)
    static let error = Color(.error)
    static let errorSoft = Color(.errorSoft)
}

// MARK: - Category Palette

enum CategoryPalette {
    nonisolated static func color(for name: String) -> Color {
        let colorMap: [String: Color] = [
            "terracotta": Color(red: 0.80, green: 0.42, blue: 0.35),
            "amber": Color(red: 0.82, green: 0.63, blue: 0.34),
            "ochre": Color(red: 0.76, green: 0.68, blue: 0.40),
            "sage": Color(red: 0.50, green: 0.63, blue: 0.48),
            "eucalyptus": Color(red: 0.42, green: 0.62, blue: 0.58),
            "slate": Color(red: 0.42, green: 0.55, blue: 0.65),
            "dusk": Color(red: 0.50, green: 0.46, blue: 0.65),
            "lavender": Color(red: 0.62, green: 0.50, blue: 0.67),
            "rose": Color(red: 0.75, green: 0.45, blue: 0.52),
            "clay": Color(red: 0.65, green: 0.50, blue: 0.44),
        ]
        return colorMap[name] ?? Color(red: 0.55, green: 0.55, blue: 0.55)
    }

    static let curated: [(name: String, label: String)] = [
        ("terracotta", "Terracotta"),
        ("amber", "Amber"),
        ("ochre", "Ochre"),
        ("sage", "Sage"),
        ("eucalyptus", "Eucalyptus"),
        ("slate", "Slate"),
        ("dusk", "Dusk"),
        ("lavender", "Lavender"),
        ("rose", "Rose"),
        ("clay", "Clay"),
    ]
}

// MARK: - Themed Screen Modifier

// periphery:ignore
struct ThemedScreen: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(AppColor.bgPrimary)
            .foregroundStyle(AppColor.textPrimary)
    }
}

extension View {
    // periphery:ignore
    func themedScreen() -> some View {
        modifier(ThemedScreen())
    }
}
