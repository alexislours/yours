import SwiftUI

extension View {
    /// Applies the app's standard plain list styling: no chrome, hidden scroll background.
    func appListStyle(animatingBy ids: [some Hashable]) -> some View {
        listStyle(.plain)
            .scrollContentBackground(.hidden)
            .animation(.listReorder, value: ids)
    }

    /// Applies the app's standard plain list styling without a reorder animation.
    func appListStyle() -> some View {
        listStyle(.plain)
            .scrollContentBackground(.hidden)
    }
}

/// Bottom spacer row to place at the end of every app List.
struct ListBottomSpacer: View {
    var body: some View {
        Color.clear
            .frame(height: Spacing.screen)
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
    }
}
