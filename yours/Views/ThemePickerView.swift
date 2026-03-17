import SwiftUI
import UIKit

struct ThemePickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var colorSchemeRaw: String
    @State private var localSelection: String

    init(colorSchemeRaw: Binding<String>) {
        _colorSchemeRaw = colorSchemeRaw
        _localSelection = State(initialValue: colorSchemeRaw.wrappedValue)
    }

    private struct ThemeOption {
        let value: String
        let label: String
        let icon: String
    }

    private let options: [ThemeOption] = [
        .init(value: "system",
              label: String(localized: "System", comment: "Theme option: follows device setting"),
              icon: "circle.lefthalf.filled"),
        .init(value: "light", label: String(localized: "Light", comment: "Theme option: always light mode"), icon: "sun.max"),
        .init(value: "dark", label: String(localized: "Dark", comment: "Theme option: always dark mode"), icon: "moon"),
    ]

    private func selectTheme(_ value: String) {
        localSelection = value // checkmark updates instantly

        guard
            let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let window = scene.windows.first,
            // afterScreenUpdates: true waits for SwiftUI to commit the checkmark
            // render before snapshotting; captures new checkmark, old colors
            let snapshot = window.snapshotView(afterScreenUpdates: true)
        else {
            colorSchemeRaw = value
            return
        }

        colorSchemeRaw = value
        // Remove any lingering snapshot from a previous rapid tap
        window.subviews.filter { $0.tag == 999 }.forEach { $0.removeFromSuperview() }
        snapshot.tag = 999
        window.addSubview(snapshot)
        UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseInOut) {
            snapshot.alpha = 0
        } completion: { _ in
            snapshot.removeFromSuperview()
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.xxxl) {
                header

                VStack(alignment: .leading, spacing: Spacing.md) {
                    Text(String(localized: "APPEARANCE", comment: "Theme picker: section header"))
                        .font(.sectionLabel)
                        .foregroundStyle(Color.textTertiary)
                        .tracking(LetterSpacing.sectionLabel)

                    VStack(spacing: 0) {
                        ForEach(Array(options.enumerated()), id: \.element.value) { index, option in
                            if index > 0 {
                                Rectangle()
                                    .fill(Color.borderSubtle)
                                    .frame(height: 1)
                                    .padding(.horizontal, Spacing.xl)
                            }

                            Button(action: { selectTheme(option.value) }, label: {
                                HStack(spacing: Spacing.md) {
                                    RoundedRectangle(cornerRadius: CornerRadius.sm)
                                        .fill(Color.accentSecondarySoft)
                                        .frame(width: 36, height: 36)
                                        .overlay(
                                            Image(systemName: option.icon)
                                                .font(.custom(FontFamily.ui, size: 16, relativeTo: .callout))
                                                .foregroundStyle(Color.accentSecondary)
                                        )

                                    Text(option.label)
                                        .font(.bodyDefault)
                                        .fontWeight(.medium)
                                        .foregroundStyle(Color.textPrimary)

                                    Spacer()

                                    if localSelection == option.value {
                                        Image(systemName: "checkmark")
                                            .font(.custom(FontFamily.ui, size: 14, relativeTo: .subheadline).weight(.semibold))
                                            .foregroundStyle(Color.accentSecondary)
                                            .accessibilityHidden(true)
                                    }
                                }
                                .padding(.horizontal, Spacing.xl)
                                .padding(.vertical, Spacing.lg)
                                .contentShape(Rectangle())
                            })
                            .buttonStyle(.plain)
                            .accessibilityAddTraits(localSelection == option.value ? .isSelected : [])
                        }
                    }
                    .background(Color.bgSurface)
                    .clipShape(RoundedRectangle(cornerRadius: CornerRadius.lg))
                    .overlay(
                        RoundedRectangle(cornerRadius: CornerRadius.lg)
                            .strokeBorder(Color.borderSubtle, lineWidth: 1)
                    )
                }
            }
            .padding(.horizontal, Spacing.xxxl)
            .padding(.bottom, Spacing.block)
        }
        .background(Color.bgPrimary)
        .navigationBarBackButtonHidden(true)
        .background(SwipeBackEnabler())
    }

    private var header: some View {
        DetailHeader(
            title: Text(String(localized: "Theme", comment: "Theme picker: screen title")),
            dismiss: dismiss
        )
    }
}
