import SwiftUI

extension View {
    /// Standard list row with hidden separator, clear background, and consistent insets.
    func plainListRow(
        top: CGFloat = Spacing.xs,
        bottom: CGFloat = Spacing.xs
    ) -> some View {
        listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets(
                top: top,
                leading: Spacing.xxxl,
                bottom: bottom,
                trailing: Spacing.xxxl
            ))
    }

    /// Card-styled list row with surface background and subtle border.
    func cardListRow() -> some View {
        listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(
                top: Spacing.xs,
                leading: Spacing.xxxl,
                bottom: Spacing.xs,
                trailing: Spacing.xxxl
            ))
            .listRowBackground(
                RoundedRectangle(cornerRadius: CornerRadius.lg)
                    .fill(Color.bgSurface)
                    .overlay(
                        RoundedRectangle(cornerRadius: CornerRadius.lg)
                            .strokeBorder(Color.borderSubtle, lineWidth: 1)
                    )
                    .padding(.vertical, Spacing.xs)
                    .padding(.horizontal, Spacing.xxxl)
            )
    }
}
