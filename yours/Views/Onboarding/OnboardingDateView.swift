import SwiftUI

struct OnboardingDateView: View {
    @Binding var startDate: Date
    let onBack: () -> Void
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: Spacing.block) {
                OnboardingPrompt(
                    title: String(localized: "When did it all start?",
                                  comment: "Onboarding date: prompt for relationship start date"),
                    hint: String(localized: "The day you became a thing.",
                                 comment: "Onboarding date: hint about the relationship start date")
                )

                VStack(spacing: Spacing.md) {
                    DatePicker(
                        String(localized: "Start date", comment: "Onboarding: label for the relationship start date picker"),
                        selection: $startDate,
                        in: ...Date.now,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.graphical)
                    .tint(Color.accentPrimary)
                    .labelsHidden()
                    .padding(Spacing.sm)
                    .background(Color.bgSurface, in: RoundedRectangle(cornerRadius: CornerRadius.xl))
                    .overlay(
                        RoundedRectangle(cornerRadius: CornerRadius.xl)
                            .strokeBorder(Color.borderSubtle, lineWidth: 1)
                    )

                    if !durationText.isEmpty {
                        Text(durationText)
                            .font(.caption)
                            .foregroundStyle(Color.textTertiary)
                            .multilineTextAlignment(.center)
                    }
                }
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

    private var durationText: String {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: startDate)
        let today = calendar.startOfDay(for: .now)
        guard start < today else { return "" }
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        formatter.allowedUnits = [.year, .month, .day]
        formatter.maximumUnitCount = 3
        guard let duration = formatter.string(from: start, to: today), !duration.isEmpty else {
            return String(localized: "Together since today.", comment: "Onboarding date: shown when the start date is today")
        }
        // swiftlint:disable:next line_length
        return String(localized: "Together for \(duration).", comment: "Onboarding date: duration since relationship started, e.g. 'Together for 2 years, 3 months.'")
    }
}

#Preview {
    OnboardingDateView(startDate: .constant(Date()), onBack: {}, onNext: {})
}
