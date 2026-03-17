import SwiftUI

struct OnboardingIntroView: View {
    let onNext: () -> Void
    @State private var appeared = false

    var body: some View {
        VStack(spacing: 0) {
            // Centered content
            VStack(spacing: Spacing.section) {
                VStack(spacing: Spacing.lg) {
                    AppIconView(size: 64)
                        .accessibilityHidden(true)

                    Text(String(localized: "Yours.", comment: "Onboarding: app name branding"))
                        .font(.displayLarge)
                        .foregroundStyle(Color.accentPrimary)
                        .tracking(LetterSpacing.displayLarge)
                }
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 12)

                VStack(spacing: Spacing.xxl) {
                    // swiftlint:disable:next line_length
                    Text(String(localized: "A place for everything\nthat makes them, them.", comment: "Onboarding intro: tagline on welcome screen"))
                        .font(.custom(FontFamily.display, size: 26, relativeTo: .title))
                        .foregroundStyle(Color.textPrimary)
                        .tracking(LetterSpacing.display)
                        .multilineTextAlignment(.center)
                        .lineSpacing(7)

                    // swiftlint:disable:next line_length
                    Text(String(localized: "Your private space to remember what they love, important dates, gift ideas\u{2026} the little things that make your relationship, yours.", comment: "Onboarding intro: description of the app's purpose"))
                        .font(.bodyDefault)
                        .foregroundStyle(Color.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(10)
                        .padding(.horizontal, Spacing.xxl)
                }
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 8)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            OnboardingPrimaryButton(
                label: String(localized: "Begin", comment: "Onboarding intro: button to start the setup flow"),
                action: onNext
            )
            .padding(.horizontal, Spacing.screen)
            .padding(.bottom, Spacing.screen)
            .opacity(appeared ? 1 : 0)
        }
        .background(Color.bgPrimary)
        .accessibilityIdentifier("view-onboarding-intro")
        .onAppear {
            withOptionalAnimation(.easeOut(duration: 0.6).delay(0.15)) {
                appeared = true
            }
        }
    }
}

#Preview {
    OnboardingIntroView(onNext: {})
}
