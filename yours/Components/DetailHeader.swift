import SwiftUI

struct DetailHeader<Trailing: View>: View {
    let title: Text
    let dismiss: DismissAction
    @ViewBuilder let trailing: Trailing

    init(
        title: Text,
        dismiss: DismissAction,
        @ViewBuilder trailing: () -> Trailing = { EmptyView() }
    ) {
        self.title = title
        self.dismiss = dismiss
        self.trailing = trailing()
    }

    var body: some View {
        HStack {
            Button(action: { dismiss() }, label: {
                Image(systemName: "chevron.left")
                    .font(.custom(FontFamily.ui, size: 17, relativeTo: .body).weight(.medium))
                    .foregroundStyle(Color.textPrimary)
                    .frame(width: 44, height: 44)
            })
            .accessibilityLabel(String(localized: "Back", comment: "Accessibility: back button"))
            .accessibilityIdentifier("btn-back")

            Spacer()

            title
                .font(.heading2)
                .foregroundStyle(Color.textPrimary)
                .tracking(-0.3)
                .lineLimit(1)

            Spacer()

            Color.clear
                .frame(width: 44, height: 44)
                .overlay(trailing)
        }
        .padding(.top, Spacing.xxxl)
        .padding(.bottom, Spacing.sm)
        .background(Color.bgPrimary)
        .overlay(alignment: .bottom) {
            LinearGradient(
                colors: [Color.bgPrimary, Color.bgPrimary.opacity(0)],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 24)
            .offset(y: 24)
            .allowsHitTesting(false)
        }
        .zIndex(1)
    }
}
