import SwiftUI

struct AppIconView: View {
    let size: CGFloat

    var body: some View {
        Image(.appIconGraphic)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: size)
    }
}

#Preview {
    AppIconView(size: 64)
}
