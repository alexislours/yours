import SwiftUI

struct CategorySectionHeader: View {
    let icon: String
    let color: Color
    let name: String

    var body: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: icon)
                .font(.custom(FontFamily.ui, size: 12, relativeTo: .caption))
                .foregroundStyle(color)
                .accessibilityHidden(true)
            Text(name.uppercased())
                .font(.sectionLabel)
                .foregroundStyle(Color.textTertiary)
                .textCase(nil)
                .accessibilityAddTraits(.isHeader)
        }
        .padding(.bottom, Spacing.xs)
    }
}
