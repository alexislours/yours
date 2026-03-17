import SwiftUI

struct AvatarView: View {
    let name: String
    let size: CGFloat
    var image: Image?

    var body: some View {
        Circle()
            .fill(Color.accentPrimary)
            .frame(width: size, height: size)
            .overlay {
                if let image {
                    image
                        .resizable()
                        .scaledToFill()
                        .clipShape(Circle())
                        .transition(.opacity)
                } else {
                    Text(String(name.prefix(1)).uppercased())
                        .font(.custom(FontFamily.display, size: size * 0.42, relativeTo: .largeTitle))
                        .fontWeight(.medium)
                        .foregroundStyle(Color.textOnAccent)
                        .baselineOffset(size * 0.03)
                        .transition(.opacity)
                }
            }
            .clipShape(Circle())
            .accessibilityLabel(
                String(
                    localized: "\(name), profile photo",
                    comment: "Accessibility: avatar image label with person's name"
                )
            )
    }
}

#Preview {
    AvatarView(name: "Jane", size: 120)
}
