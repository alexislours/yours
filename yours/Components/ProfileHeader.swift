import os
import SwiftData
import SwiftUI
import UIKit

struct ProfileHeader: View {
    let person: Person
    let reminder: Reminder?
    var onSettingsTapped: (() -> Void)?

    @Environment(\.modelContext) private var modelContext
    @State private var avatarImage: Image?
    @State private var avatarID = UUID()
    @State private var showingPicker = false
    @State private var showingOptions = false
    @State private var pendingImage: UIImage?

    struct Reminder {
        let icon: String
        let text: String
        let color: Color
    }

    var body: some View {
        VStack(spacing: Spacing.lg) {
            // Top row: spacer | title | settings
            HStack {
                // Spacer to balance settings icon
                Color.clear
                    .frame(width: 44, height: 44)
                    .accessibilityHidden(true)

                Spacer()

                HStack(spacing: 0) {
                    Text(String(localized: "Yours, about ",
                                comment: "Profile header: prefix before person's name in 'Yours, about [name].'"))
                        .font(.heading3)
                        .fontWeight(.light)
                        .foregroundStyle(Color.textSecondary)
                        .tracking(-0.3)

                    Text(person.firstName)
                        .font(.heading3)
                        .fontWeight(.medium)
                        .foregroundStyle(Color.accentPrimary)
                        .tracking(-0.3)

                    Text(String(localized: ".", comment: "Profile header: punctuation after person's name in 'Yours, about [name].'"))
                        .font(.heading3)
                        .fontWeight(.light)
                        .foregroundStyle(Color.textSecondary)
                        .tracking(-0.3)
                }

                Spacer()

                if let onSettingsTapped {
                    Button(action: onSettingsTapped) {
                        Image(systemName: "gearshape")
                            .font(.custom(FontFamily.ui, size: 22, relativeTo: .title2))
                            .foregroundStyle(Color.textTertiary)
                            .frame(width: 44, height: 44)
                    }
                    .accessibilityLabel(String(localized: "Settings", comment: "Accessibility: settings button label"))
                } else {
                    Color.clear
                        .frame(width: 44, height: 44)
                        .accessibilityHidden(true)
                }
            }

            // Avatar
            Button {
                if avatarImage != nil {
                    showingOptions = true
                } else {
                    showingPicker = true
                }
            } label: {
                AvatarView(name: person.firstName, size: 120, image: avatarImage)
                    .id(avatarID)
                    .overlay(alignment: .bottomTrailing) {
                        if avatarImage == nil {
                            Image(systemName: "camera.fill")
                                .font(.custom(FontFamily.ui, size: 12, relativeTo: .caption))
                                .foregroundStyle(Color.textOnAccent)
                                .frame(width: 28, height: 28)
                                .background(Color.accentPrimary)
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(Color.bgSubtle, lineWidth: 2)
                                )
                                .transition(.scale.combined(with: .opacity))
                                .accessibilityHidden(true)
                        }
                    }
            }
            .accessibilityLabel(
                avatarImage != nil
                    ? String(
                        localized: "\(person.firstName)'s profile photo",
                        comment: "Accessibility: avatar button label when photo is set"
                    )
                    : String(
                        localized: "Add photo for \(person.firstName)",
                        comment: "Accessibility: avatar button label when no photo"
                    )
            )
            .confirmationDialog(
                String(localized: "Profile Photo", comment: "Profile header: title for photo action sheet"),
                isPresented: $showingOptions,
                titleVisibility: .hidden
            ) {
                Button(String(localized: "Change Photo", comment: "Profile header: option to change profile photo")) {
                    showingPicker = true
                }
                Button(
                    String(localized: "Remove Photo", comment: "Profile header: destructive option to delete profile photo"),
                    role: .destructive
                ) {
                    person.photoData = nil
                    do {
                        try modelContext.save()
                    } catch {
                        Logger(subsystem: Bundle.main.bundleIdentifier ?? "", category: "data")
                            .error("Failed to save after removing photo: \(error)")
                    }
                    withOptionalAnimation(.easeInOut(duration: 0.35)) {
                        avatarImage = nil
                        avatarID = UUID()
                    }
                }
            }
            .sheet(isPresented: $showingPicker, onDismiss: applyPendingImage) {
                ImagePickerSheet { uiImage in
                    pendingImage = uiImage
                }
            }

            // Duration text
            Text(person.durationDescription)
                .font(.custom(FontFamily.display, size: 17, relativeTo: .title3))
                .foregroundStyle(Color.textPrimary)
                .tracking(-0.2)
                .lineSpacing(4)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 300)

            // Reminder pill
            if let reminder {
                ReminderPill(
                    icon: reminder.icon,
                    text: reminder.text,
                    color: reminder.color
                )
            }
        }
        .padding(.horizontal, Spacing.xxxl)
        .padding(.top, Spacing.lg)
        .padding(.bottom, Spacing.xxxl)
        .background(Color.bgSubtle)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.xl))
        .task {
            guard let data = person.photoData else { return }
            if let decoded = await decodeImage(from: data) {
                avatarImage = decoded
            }
        }
    }

    private func applyPendingImage() {
        guard let uiImage = pendingImage else { return }
        pendingImage = nil
        Task {
            let resized = await Task.detached {
                uiImage.resizedTo512()
            }.value
            person.photoData = resized.jpegData(compressionQuality: 0.8)
            do {
                try modelContext.save()
            } catch {
                Logger(subsystem: Bundle.main.bundleIdentifier ?? "", category: "data")
                    .error("Failed to save after setting photo: \(error)")
            }
            withOptionalAnimation(.easeInOut(duration: 0.35)) {
                avatarImage = Image(uiImage: resized)
                avatarID = UUID()
            }
        }
    }
}

// MARK: - UIImage resize helper (internal, used by OnboardingFlow too)

extension UIImage {
    nonisolated func resizedTo512() -> UIImage {
        let size = CGSize(width: 512, height: 512)
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}

#Preview {
    ProfileHeader(
        person: .preview,
        reminder: .init(
            icon: "gift",
            text: "Her birthday is in 12 days",
            color: .accentPrimary
        )
    )
    .padding(.horizontal, Spacing.xxxl)
    .background(Color.bgPrimary)
}
