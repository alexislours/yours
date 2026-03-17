import SwiftUI

struct OnboardingPhotoView: View {
    let name: String
    @Binding var photo: UIImage?
    let onBack: () -> Void
    let onNext: () -> Void
    let onSkip: () -> Void

    @State private var showingPicker = false

    var body: some View {
        VStack(spacing: 0) {
            // Centered content
            VStack(spacing: Spacing.xxxl) {
                styledHeading(String(
                    localized: "Give \(name) a face",
                    comment: "Onboarding photo: heading with person's name - translators can reorder"
                ))

                // Photo circle
                ZStack {
                    Circle()
                        .fill(Color.bgSubtle)
                        .frame(width: 160, height: 160)
                        .overlay(Circle().strokeBorder(Color.borderDefault, lineWidth: 1))

                    if let photo {
                        Image(uiImage: photo)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 160, height: 160)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: "person.fill")
                            .font(.custom(FontFamily.ui, size: 52, relativeTo: .largeTitle))
                            .foregroundStyle(Color.borderStrong)
                            .accessibilityHidden(true)
                    }
                }

                // Choose photo button
                Button {
                    showingPicker = true
                } label: {
                    HStack(spacing: Spacing.sm) {
                        Image(systemName: "camera")
                            .font(.custom(FontFamily.ui, size: 14, relativeTo: .subheadline))
                        Text(String(localized: "Choose a photo", comment: "Onboarding photo: button to pick a photo from library"))
                            .font(.label)
                    }
                    .foregroundStyle(Color.accentPrimary)
                    .padding(.vertical, Spacing.md)
                    .padding(.horizontal, Spacing.xxl)
                    .background(Color.bgSurface, in: Capsule())
                    .overlay(Capsule().strokeBorder(Color.borderDefault, lineWidth: 1))
                }
                .sheet(isPresented: $showingPicker) {
                    ImagePickerSheet { uiImage in
                        photo = uiImage
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            VStack(spacing: Spacing.lg) {
                OnboardingPrimaryButton(
                    label: String(localized: "Next", comment: "Onboarding: button to proceed to the next step"),
                    enabled: photo != nil,
                    action: onNext
                )

                Button(String(localized: "Skip for now", comment: "Onboarding: button to skip an optional step"), action: onSkip)
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
}

#Preview {
    OnboardingPhotoView(name: "Jane", photo: .constant(nil), onBack: {}, onNext: {}, onSkip: {})
}
