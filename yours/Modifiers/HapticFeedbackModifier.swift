import SwiftUI

extension View {
    func hapticFeedback(_ feedback: SensoryFeedback, trigger: some Equatable) -> some View {
        modifier(HapticFeedbackModifier(feedback: feedback, trigger: trigger))
    }
}

private struct HapticFeedbackModifier<T: Equatable>: ViewModifier {
    let feedback: SensoryFeedback
    let trigger: T
    @AppStorage(UserDefaultsKeys.hapticsEnabled) private var hapticsEnabled = true

    func body(content: Content) -> some View {
        if hapticsEnabled {
            content.sensoryFeedback(feedback, trigger: trigger)
        } else {
            content
        }
    }
}
