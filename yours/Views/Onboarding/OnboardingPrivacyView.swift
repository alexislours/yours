import SwiftUI

struct OnboardingPrivacyView: View {
    let onBack: () -> Void
    let onNext: () -> Void

    @State private var appeared = false

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: Spacing.section) {
                VStack(spacing: Spacing.lg) {
                    Image(systemName: "lock.fill")
                        .font(.custom(FontFamily.ui, size: 28, relativeTo: .title))
                        .foregroundStyle(Color.accentPrimary)
                        .opacity(0.5)
                        .accessibilityHidden(true)

                    OnboardingPrompt(
                        title: String(localized: "Your eyes only.", comment: "Onboarding privacy: headline about data privacy"),
                        hint: String(localized: "Here's how we keep it that way.",
                                     comment: "Onboarding privacy: subtitle about privacy approach")
                    )
                }

                VStack(alignment: .leading, spacing: Spacing.xl) {
                    PrivacyRow(
                        icon: "eye.slash",
                        text: String(localized: "No tracking, no analytics, no peeking.",
                                     comment: "Onboarding privacy: first privacy bullet point"),
                        appeared: appeared, index: 0
                    )
                    PrivacyRow(
                        icon: "hand.raised",
                        text: String(localized: "No accounts, no sign-ups, no strings.",
                                     comment: "Onboarding privacy: second privacy bullet point"),
                        appeared: appeared, index: 1
                    )
                    PrivacyRow(
                        icon: "square.and.arrow.up",
                        text: String(localized: "Export your data anytime. It's yours.",
                                     comment: "Onboarding privacy: third privacy bullet point"),
                        appeared: appeared, index: 2
                    )
                }
                .onAppear {
                    Task {
                        try? await Task.sleep(for: .seconds(0.4))
                        appeared = true
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, Spacing.screen)

            OnboardingPrimaryButton(
                label: String(localized: "Got it", comment: "Onboarding privacy: acknowledgment button"),
                action: onNext
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
    }
}

private struct PrivacyRow: View {
    let icon: String
    let text: String
    let appeared: Bool
    let index: Int

    var body: some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: icon)
                .font(.custom(FontFamily.ui, size: 18, relativeTo: .title3))
                .foregroundStyle(Color.accentPrimary)
                .frame(width: 28)
                .accessibilityHidden(true)
            Text(text)
                .font(.bodyDefault)
                .foregroundStyle(Color.textSecondary)
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 8)
        .animation(.motionAware(.easeOut(duration: 0.35).delay(Double(index) * 0.25)), value: appeared)
    }
}

#Preview {
    OnboardingPrivacyView(onBack: {}, onNext: {})
}
