import SwiftUI

struct SearchBar: View {
    let placeholder: String
    @Binding var text: String
    var requestFocus: Bool = false

    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: "magnifyingglass")
                .font(.custom(FontFamily.ui, size: 14, relativeTo: .subheadline))
                .foregroundStyle(Color.textTertiary)
                .accessibilityHidden(true)

            TextField(placeholder, text: $text)
                .font(.bodyDefault)
                .foregroundStyle(Color.textPrimary)
                .focused($isFocused)

            if !text.isEmpty {
                Button(action: { text = "" }, label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.custom(FontFamily.ui, size: 14, relativeTo: .subheadline))
                        .foregroundStyle(Color.textTertiary)
                })
                .accessibilityLabel(
                    String(localized: "Clear search", comment: "Accessibility: clear search field")
                )
            }
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.md)
        .background(Color.bgSurface)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: CornerRadius.lg)
                .strokeBorder(Color.borderSubtle, lineWidth: 1)
        )
        .onAppear {
            if requestFocus {
                isFocused = true
            }
        }
    }
}
