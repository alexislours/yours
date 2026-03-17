import SwiftUI

struct ListScaffold<Header: View, EmptyContent: View, Content: View, FAB: View>: View {
    let isEmpty: Bool
    @ViewBuilder let header: () -> Header
    @ViewBuilder let emptyContent: () -> EmptyContent
    @ViewBuilder let content: () -> Content
    @ViewBuilder let fab: () -> FAB

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 0) {
                header()
                    .padding(.horizontal, Spacing.xxxl)

                if isEmpty {
                    Spacer()
                    emptyContent()
                        .padding(.horizontal, Spacing.xxxl)
                    Spacer()
                } else {
                    content()
                        .transition(.opacity)
                }
            }
            .animation(.emptyState, value: isEmpty)

            if !isEmpty {
                fab()
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.bgPrimary)
    }
}
