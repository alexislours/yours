import SwiftUI

protocol PredefinedCategoryType: RawRepresentable, CaseIterable, Sendable
    where RawValue == String {
    var displayName: String { get }
    var icon: String { get }
    var colorName: String { get }
    var color: Color { get }
    var isHideable: Bool { get }
}

extension PredefinedCategoryType {
    var color: Color {
        CategoryPalette.color(for: colorName)
    }

    var isHideable: Bool {
        false
    }

    static func filterByVisibility(
        hiddenRaw: String
    ) -> (visible: [Self], hidden: [Self]) {
        let hiddenSet = Set(hiddenRaw.split(separator: ",").map(String.init))
        let visible = allCases.filter { !hiddenSet.contains($0.rawValue) }
        let hidden = allCases.filter { hiddenSet.contains($0.rawValue) }
        return (visible, hidden)
    }
}
