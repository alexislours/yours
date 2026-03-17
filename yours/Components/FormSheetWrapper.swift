import SwiftUI

struct FormSheetWrapper<Content: View>: View {
    let title: Text
    let canSave: Bool
    let detents: Set<PresentationDetent>
    let onSave: () -> Void
    @ViewBuilder let content: Content
    @Environment(\.dismiss) private var dismiss

    init(
        title: Text,
        canSave: Bool,
        detents: Set<PresentationDetent> = [.medium, .large],
        onSave: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.canSave = canSave
        self.detents = detents
        self.onSave = onSave
        self.content = content()
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                DetailHeader(title: title, dismiss: dismiss) {
                    Button {
                        HapticFeedback.fire(.success)
                        onSave()
                    } label: {
                        Image(systemName: "checkmark")
                            .font(.custom(FontFamily.ui, size: 16, relativeTo: .callout).weight(.medium))
                            .foregroundStyle(canSave ? Color.accentPrimary : Color.textDisabled)
                            .animation(.motionAware(.easeInOut(duration: 0.2)), value: canSave)
                            .contentTransition(.symbolEffect(.replace))
                    }
                    .disabled(!canSave)
                }
                .padding(.horizontal, Spacing.xxxl)

                ScrollView {
                    VStack(alignment: .leading, spacing: Spacing.xxxl) {
                        content
                    }
                    .padding(.horizontal, Spacing.xxxl)
                    .padding(.top, Spacing.lg)
                    .padding(.bottom, Spacing.screen)
                }
            }
            .background(Color.bgPrimary)
            .navigationBarBackButtonHidden(true)
        }
        .presentationDetents(detents)
        .presentationDragIndicator(.visible)
    }
}
