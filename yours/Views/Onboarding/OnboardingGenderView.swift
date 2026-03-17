import SwiftUI

struct OnboardingGenderView: View {
    let name: String
    @Binding var gender: Person.Gender
    let onBack: () -> Void
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Centered content
            VStack(spacing: Spacing.block) {
                // Prompt with name
                VStack(spacing: Spacing.md) {
                    styledHeading(String(
                        localized: "\(name) is\u{2026}",
                        comment: "Onboarding gender: prompt with name followed by gender options - translators can reorder"
                    ))

                    // swiftlint:disable:next line_length
                    Text(String(localized: "So we use the right words for them.", comment: "Onboarding gender: explains why we ask for gender (pronoun selection)"))
                        .font(.bodyDefault)
                        .foregroundStyle(Color.textTertiary)
                        .multilineTextAlignment(.center)
                }

                // Selection pills
                VStack(spacing: Spacing.md) {
                    genderPill(String(localized: "A woman", comment: "Onboarding gender: female option"), value: .female)
                    genderPill(String(localized: "A man", comment: "Onboarding gender: male option"), value: .male)
                    genderPill(String(localized: "Non-binary", comment: "Onboarding gender: non-binary option"), value: .other)
                }
                .hapticFeedback(.selection, trigger: gender)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, Spacing.screen)

            OnboardingPrimaryButton(
                label: String(localized: "Next", comment: "Onboarding: button to proceed to the next step"),
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

    private func styledHeading(_ fullString: String) -> some View {
        var attributed = AttributedString(fullString)
        if let range = attributed.range(of: name) {
            attributed[range].foregroundColor = Color.accentPrimary
        }
        return Text(attributed)
            .font(.heading1)
            .foregroundStyle(Color.textPrimary)
            .tracking(-0.3)
    }

    @ViewBuilder
    private func genderPill(_ label: String, value: Person.Gender) -> some View {
        let isSelected = gender == value
        Button { gender = value } label: {
            Text(label)
                .font(.bodyDefault)
                .foregroundStyle(isSelected ? Color.accentPrimary : Color.textPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.lg)
        }
        .background(Color.bgSurface, in: RoundedRectangle(cornerRadius: CornerRadius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: CornerRadius.lg)
                .strokeBorder(
                    isSelected ? Color.accentPrimary : Color.borderSubtle,
                    lineWidth: isSelected ? 1.5 : 1
                )
        )
        .animation(.motionAware(.easeInOut(duration: 0.2)), value: isSelected)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    OnboardingGenderView(name: "Jane", gender: .constant(.female), onBack: {}, onNext: {})
}
