import SwiftUI

struct OnboardingLikeView: View {
    let gender: Person.Gender
    @Binding var firstLike: String
    let onBack: () -> Void
    let onFinish: () -> Void

    @FocusState private var isLikeFocused: Bool
    @State private var pendingFinish = false

    private func gendered(female: String, male: String, other: String) -> String {
        switch gender {
        case .female: female
        case .male: male
        case .other: other
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: Spacing.block) {
                OnboardingPrompt(
                    title: gendered(
                        female: String(localized: "One thing she loves", comment: "Onboarding like: prompt, female"),
                        male: String(localized: "One thing he loves", comment: "Onboarding like: prompt, male"),
                        other: String(localized: "One thing they love", comment: "Onboarding like: prompt, non-binary")
                    ),
                    hint: gendered(
                        female: String(localized: "Something she can't resist. Anything at all.", comment: "Onboarding like: hint, female"),
                        male: String(localized: "Something he can't resist. Anything at all.", comment: "Onboarding like: hint, male"),
                        // swiftlint:disable:next line_length
                        other: String(localized: "Something they can't resist. Anything at all.", comment: "Onboarding like: hint, non-binary")
                    )
                )

                // Category input card
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    ZStack(alignment: .leading) {
                        if firstLike.isEmpty {
                            // swiftlint:disable:next line_length
                            Text(String(localized: "Something they love\u{2026}", comment: "Onboarding like: placeholder for the thing they love input"))
                                .font(.custom(FontFamily.display, size: 20, relativeTo: .title2).weight(.light))
                                .foregroundStyle(Color.textDisabled)
                                .tracking(-0.2)
                        }
                        TextField(text: $firstLike) {}
                            .font(.custom(FontFamily.display, size: 20, relativeTo: .title2).weight(.light))
                            .foregroundStyle(Color.textPrimary)
                            .tracking(-0.2)
                            .textFieldStyle(.plain)
                            .focused($isLikeFocused)
                            .autocorrectionDisabled()
                            .onSubmit {
                                if !firstLike.isEmpty { dismissKeyboardThenFinish() }
                            }
                    }
                }
                .padding(Spacing.xl)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.bgSurface, in: RoundedRectangle(cornerRadius: CornerRadius.lg))
                .overlay(
                    RoundedRectangle(cornerRadius: CornerRadius.lg)
                        .strokeBorder(Color.borderSubtle, lineWidth: 1)
                )
                .onTapGesture { isLikeFocused = true }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, Spacing.block)

            VStack(spacing: Spacing.lg) {
                OnboardingPrimaryButton(
                    label: String(localized: "Save & finish", comment: "Onboarding like: final button to save and complete setup"),
                    enabled: firstLike.nonBlank != nil,
                    action: { dismissKeyboardThenFinish() }
                )

                Button(String(localized: "Skip for now", comment: "Onboarding: button to skip an optional step")) {
                    firstLike = ""
                    dismissKeyboardThenFinish()
                }
                .font(.bodySmall)
                .foregroundStyle(Color.textTertiary)
            }
            .padding(.horizontal, Spacing.screen)
            .padding(.bottom, Spacing.screen)
        }
        .overlay(alignment: .topLeading) {
            OnboardingBackButton(action: onBack)
                .padding(.leading, Spacing.sm)
                .padding(.top, Spacing.sm)
        }
        .background(Color.bgPrimary)
        .onAppear { isLikeFocused = true }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { notification in
            guard pendingFinish else { return }
            pendingFinish = false
            let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0.25
            Task {
                try? await Task.sleep(for: .seconds(duration + 0.30))
                onFinish()
            }
        }
    }

    private func dismissKeyboardThenFinish() {
        pendingFinish = true
        // Direct UIKit call; immediate, bypasses SwiftUI render cycle
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        // Fallback for external keyboards where the notification never fires
        Task {
            try? await Task.sleep(for: .seconds(0.6))
            guard pendingFinish else { return }
            pendingFinish = false
            onFinish()
        }
    }
}

#Preview {
    OnboardingLikeView(
        gender: .female,
        firstLike: .constant(""),
        onBack: {},
        onFinish: {}
    )
}
