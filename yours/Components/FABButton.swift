import SwiftUI

struct FABButton: View {
    let accessibilityLabel: LocalizedStringResource
    let action: () -> Void
    @State private var tapCount = 0

    var body: some View {
        Button {
            tapCount += 1
            action()
        } label: {
            Image(systemName: "plus")
                .font(.custom(FontFamily.ui, size: 20, relativeTo: .title3).weight(.semibold))
                .foregroundStyle(Color.textOnAccent)
                .frame(width: 52, height: 52)
                .background(Color.accentPrimary, in: Circle())
                .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.pressable)
        .hapticFeedback(.impact(weight: .medium), trigger: tapCount)
        .accessibilityLabel(String(localized: accessibilityLabel))
        .padding(.trailing, Spacing.xxxl)
        .padding(.bottom, Spacing.xxxl)
    }
}
