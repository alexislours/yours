import SwiftUI

struct WidgetAvatarView: View {
    let name: String
    let size: CGFloat

    var body: some View {
        Circle()
            .fill(Color(.accentPrimary))
            .frame(width: size, height: size)
            .overlay {
                Text(String(name.prefix(1)).uppercased())
                    .font(.custom("Crimson Pro", size: size * 0.42, relativeTo: .largeTitle))
                    .fontWeight(.medium)
                    .foregroundStyle(Color(.textOnAccent))
            }
            .clipShape(Circle())
            .accessibilityLabel(name)
    }
}
