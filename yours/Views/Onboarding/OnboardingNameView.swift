import SwiftUI

struct OnboardingNameView: View {
    @Binding var name: String
    let onBack: () -> Void
    let onNext: () -> Void

    @FocusState private var isFocused: Bool

    private var canAdvance: Bool {
        name.nonBlank != nil
    }

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: Spacing.block) {
                OnboardingPrompt(
                    // swiftlint:disable:next line_length
                    title: String(localized: "Who are you doing this for?", comment: "Onboarding name: prompt asking who the user is creating a profile for"),
                    hint: String(localized: "Their first name is perfect.", comment: "Onboarding name: hint to enter a first name")
                )

                // Large underline text input
                VStack(alignment: .center, spacing: 0) {
                    ZStack {
                        if name.isEmpty {
                            Text(String(localized: "Their name", comment: "Onboarding name: placeholder text for the name input field"))
                                .font(.custom(FontFamily.display, size: 32, relativeTo: .largeTitle).weight(.light))
                                .foregroundStyle(Color.textDisabled)
                                .tracking(-0.3)
                        }

                        TextField(text: $name) {}
                            .font(.custom(FontFamily.display, size: 32, relativeTo: .largeTitle).weight(.light))
                            .foregroundStyle(Color.accentPrimary)
                            .tracking(-0.3)
                            .multilineTextAlignment(.center)
                            .textFieldStyle(.plain)
                            .focused($isFocused)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.words)
                            .onSubmit { if canAdvance { isFocused = false; onNext() } }
                    }

                    Rectangle()
                        .fill(Color.borderDefault)
                        .frame(height: 1)
                        .padding(.top, Spacing.md)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, Spacing.screen)

            OnboardingPrimaryButton(
                label: String(localized: "Next", comment: "Onboarding: button to proceed to the next step"),
                enabled: canAdvance,
                action: { isFocused = false; onNext() }
            )
            .padding(.horizontal, Spacing.screen)
            .padding(.bottom, Spacing.screen)
        }
        .overlay(alignment: .topLeading) {
            OnboardingBackButton(action: onBack)
                .padding(.leading, Spacing.sm)
                .padding(.top, Spacing.sm)
        }
        .background(Color.bgPrimary)
        .onAppear { isFocused = true }
    }
}

#Preview {
    OnboardingNameView(name: .constant(""), onBack: {}, onNext: {})
}
