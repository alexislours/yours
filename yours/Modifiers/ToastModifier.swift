import SwiftUI

extension View {
    func toast(_ message: String, isPresented: Binding<Bool>, duration: TimeInterval = 2.0) -> some View {
        modifier(ToastModifier(message: message, isPresented: isPresented, duration: duration))
    }
}

struct ToastModifier: ViewModifier {
    let message: String
    @Binding var isPresented: Bool
    var duration: TimeInterval = 2.0
    @State private var dismissTask: Task<Void, Never>?

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .bottom) {
                if isPresented {
                    Text(message)
                        .font(.bodySmall)
                        .fontWeight(.medium)
                        .foregroundStyle(Color.white)
                        .padding(.horizontal, Spacing.xl)
                        .padding(.vertical, Spacing.md)
                        .background(Color.textPrimary.opacity(0.9))
                        .clipShape(Capsule())
                        .padding(.bottom, Spacing.xxxl)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .hapticFeedback(.impact(weight: .light), trigger: isPresented)
            .animation(.motionAware(.easeOut(duration: 0.3)), value: isPresented)
            .onChange(of: isPresented) { _, newValue in
                dismissTask?.cancel()
                if newValue {
                    dismissTask = Task {
                        try? await Task.sleep(for: .seconds(duration))
                        isPresented = false
                    }
                }
            }
    }
}
