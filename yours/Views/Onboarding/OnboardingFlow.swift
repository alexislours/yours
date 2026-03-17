import SwiftData
import SwiftUI
import UIKit

struct OnboardingFlow: View {
    @Environment(\.modelContext) private var modelContext

    @State private var step = 0
    @State private var isGoingBack = false
    @State private var name = ""
    @State private var photo: UIImage?
    @State private var gender: Person.Gender = .female
    @State private var startDate = Date()
    @State private var firstLike = ""

    private let totalSteps = 6

    var body: some View {
        ZStack {
            stepView
                .id(step)
                .transition(.asymmetric(
                    insertion: .move(edge: isGoingBack ? .leading : .trailing).combined(with: .opacity),
                    removal: .move(edge: isGoingBack ? .trailing : .leading).combined(with: .opacity)
                ))
        }
        .overlay(alignment: .top) {
            if step > 0 {
                OnboardingStepIndicator(current: step, total: totalSteps)
                    .padding(.top, Spacing.sm)
            }
        }
        .background(Color.bgPrimary)
        .animation(.motionAware(.easeInOut(duration: 0.35)), value: step)
        .gesture(
            DragGesture(minimumDistance: 30)
                .onEnded { value in
                    if step > 0, value.translation.width > 80 {
                        goBack()
                    }
                }
        )
    }

    @ViewBuilder
    private var stepView: some View {
        switch step {
        case 0:
            OnboardingIntroView(onNext: advance)
        case 1:
            OnboardingPrivacyView(onBack: goBack, onNext: advance)
        case 2:
            OnboardingNameView(name: $name, onBack: goBack, onNext: advance)
        case 3:
            OnboardingPhotoView(name: name, photo: $photo, onBack: goBack, onNext: advance, onSkip: advance)
        case 4:
            OnboardingGenderView(name: name, gender: $gender, onBack: goBack, onNext: advance)
        case 5:
            OnboardingDateView(startDate: $startDate, onBack: goBack, onNext: advance)
        case 6:
            OnboardingLikeView(
                gender: gender,
                firstLike: $firstLike,
                onBack: goBack,
                onFinish: finish
            )
        default:
            EmptyView()
        }
    }

    private func advance() {
        isGoingBack = false
        step += 1
    }

    private func goBack() {
        guard step > 0 else { return }
        isGoingBack = true
        step -= 1
    }

    private func finish() {
        let input = OnboardingService.Input(
            name: name,
            photo: photo,
            gender: gender,
            startDate: startDate,
            firstLike: firstLike
        )
        Task {
            await OnboardingService.complete(input, modelContext: modelContext)
        }
    }
}

// MARK: - Shared Onboarding Components

struct OnboardingPrompt: View {
    let title: String
    let hint: String

    var body: some View {
        VStack(spacing: Spacing.md) {
            Text(title)
                .font(.heading1)
                .foregroundStyle(Color.textPrimary)
                .tracking(-0.3)
                .multilineTextAlignment(.center)

            Text(hint)
                .font(.bodyDefault)
                .foregroundStyle(Color.textTertiary)
                .multilineTextAlignment(.center)
        }
    }
}

struct OnboardingBackButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "chevron.left")
                .font(.custom(FontFamily.ui, size: 17, relativeTo: .body).weight(.medium))
                .foregroundStyle(Color.textSecondary)
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
        .accessibilityLabel(String(localized: "Back", comment: "Accessibility: back button"))
    }
}

struct OnboardingStepIndicator: View {
    let current: Int
    let total: Int

    var body: some View {
        HStack(spacing: Spacing.xs) {
            ForEach(1 ... total, id: \.self) { index in
                Capsule()
                    .fill(index <= current ? Color.accentPrimary : Color.borderSubtle)
                    .frame(width: index == current ? 20 : 8, height: 4)
                    .animation(.motionAware(.spring(response: 0.4, dampingFraction: 0.75)), value: current)
            }
        }
        .accessibilityElement()
        .accessibilityLabel(
            String(
                localized: "Step \(current) of \(total)",
                comment: "Accessibility: onboarding progress indicator, e.g. 'Step 3 of 6'"
            )
        )
    }
}

struct OnboardingPrimaryButton: View {
    let label: String
    let enabled: Bool
    let action: () -> Void

    init(label: String, enabled: Bool = true, action: @escaping () -> Void) {
        self.label = label
        self.enabled = enabled
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.label)
                .foregroundStyle(enabled ? Color.textOnAccent : Color.textDisabled)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.lg)
                .background(enabled ? Color.accentPrimary : Color.bgMuted, in: Capsule())
        }
        .buttonStyle(.pressable)
        .disabled(!enabled)
    }
}
