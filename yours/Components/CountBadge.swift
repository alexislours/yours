import SwiftUI

struct CountBadge: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundStyle(Color.textTertiary)
            .padding(.vertical, 3)
            .padding(.horizontal, Spacing.sm)
            .background(Color.bgMuted, in: Capsule())
    }
}

#Preview {
    CountBadge(text: "8 dates")
}
