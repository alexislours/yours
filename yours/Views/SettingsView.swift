import CloudKit
import SwiftData
import SwiftUI
import UIKit
import UniformTypeIdentifiers
import UserNotifications

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    @Environment(\.scenePhase) var scenePhase
    @Query var persons: [Person]

    @AppStorage(UserDefaultsKeys.appColorScheme) var colorSchemeRaw: String = "system"
    @AppStorage(UserDefaultsKeys.devModeEnabled) var devModeEnabled = false
    @AppStorage(UserDefaultsKeys.notificationHour) var notificationHour = 9
    @AppStorage(UserDefaultsKeys.notificationMinute) var notificationMinute = 0
    @AppStorage(UserDefaultsKeys.notificationTimeSet) var notificationTimeSet = false
    @AppStorage(UserDefaultsKeys.notificationsEnabled) var notificationsEnabled = true
    @AppStorage(UserDefaultsKeys.currencyCode) var currencyCode: String = Locale.current.currency?.identifier ?? "USD"
    @AppStorage(UserDefaultsKeys.hapticsEnabled) var hapticsEnabled = true

    @State var showStartOverAlert = false
    @State var showResetPostOnboardingAlert = false
    @State var shareFile: ShareFile?
    @State var showImporter = false
    @State var importError: String?
    @State var showImportError = false
    @State var showImportSuccess = false
    @State var versionTapCount = 0
    @State var showDevModeToast = false
    @State var showProfileEditor = false
    @State var cloudKitStatus: CKAccountStatus?
    @State var avatarImage: Image?

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.xxxl) {
                header

                VStack(spacing: Spacing.xxxl) {
                    profileSection
                    appearanceSection
                    notificationsSection
                    syncSection
                    dataSection
                    aboutSection

                    if devModeEnabled {
                        developerSection
                    }
                }

                footer
            }
            .padding(.horizontal, Spacing.xxxl)
            .padding(.bottom, Spacing.block)
        }
        .background(Color.bgPrimary)
        .navigationBarBackButtonHidden(true)
        .background(SwipeBackEnabler())
        .alert(
            String(localized: "Start Over?", comment: "Settings: destructive alert title for deleting all data"),
            isPresented: $showStartOverAlert
        ) {
            Button(
                String(localized: "Delete Everything", comment: "Settings: destructive button that erases all user data"),
                role: .destructive
            ) { startOver() }
            Button(String(localized: "Cancel", comment: "Generic cancel button"), role: .cancel) {}
        } message: {
            // swiftlint:disable:next line_length
            Text(String(localized: "This will delete all your data and cannot be undone.", comment: "Settings: warning message for start-over action"))
        }
        .alert(
            String(localized: "Reset Post-Onboarding Data?", comment: "Settings: dev-mode alert title for resetting post-onboarding data"),
            isPresented: $showResetPostOnboardingAlert
        ) {
            Button(
                String(localized: "Reset", comment: "Settings: destructive button to reset post-onboarding data"),
                role: .destructive
            ) { resetPostOnboarding() }
            Button(String(localized: "Cancel", comment: "Generic cancel button"), role: .cancel) {}
        } message: {
            // swiftlint:disable:next line_length
            Text(String(localized: "This will clear all data added after onboarding (birthday, etc.) so you can test the new-user experience.", comment: "Settings: warning for resetting post-onboarding data"))
        }
        .sheet(isPresented: $showProfileEditor) {
            if let person {
                ProfileEditorSheet(person: person)
            }
        }
        .sheet(item: $shareFile) { file in
            ActivityShareSheet(items: [file.url])
        }
        .fileImporter(
            isPresented: $showImporter,
            allowedContentTypes: [.json, .zip]
        ) { result in
            handleImport(result: result)
        }
        .alert(
            String(localized: "Import Failed", comment: "Settings: alert title when data import fails"),
            isPresented: $showImportError
        ) {
            Button(String(localized: "OK", comment: "Generic OK button"), role: .cancel) {}
        } message: {
            Text(importError ?? String(localized: "Could not read the file.",
                                       comment: "Settings: fallback error message for import failure"))
        }
        .alert(
            String(localized: "Import Successful", comment: "Settings: alert title when data import succeeds"),
            isPresented: $showImportSuccess
        ) {
            Button(String(localized: "OK", comment: "Generic OK button"), role: .cancel) {}
        } message: {
            Text(String(localized: "Your data has been restored.", comment: "Settings: success message after importing data"))
        }
        .toast(
            String(localized: "Developer Mode Enabled", comment: "Settings: toast shown when developer mode is activated"),
            isPresented: $showDevModeToast
        )
        .task(id: scenePhase) {
            guard scenePhase == .active else { return }
            await refreshCloudKitStatus()
        }
    }

    // MARK: - Header

    var header: some View {
        DetailHeader(
            title: Text(String(localized: "Settings", comment: "Settings: screen title")),
            dismiss: dismiss
        )
    }

    // MARK: - Footer

    var footer: some View {
        VStack(spacing: Spacing.xxs) {
            Text(String(localized: "Made with love", comment: "Settings: footer tagline"))
                .font(.custom(FontFamily.display, size: 14, relativeTo: .subheadline))
                .fontWeight(.light)
                .foregroundStyle(Color.textTertiary)
                .tracking(-0.2)

            Text(String(localized: "Yours.", comment: "Settings: app name branding"))
                .font(.custom(FontFamily.display, size: 16, relativeTo: .body))
                .fontWeight(.medium)
                .foregroundStyle(Color.accentPrimary)
                .tracking(-0.3)
        }
        .padding(.top, Spacing.sm)
        .padding(.bottom, Spacing.lg)
    }

    // MARK: - Reusable Components

    var rowDivider: some View {
        Rectangle()
            .fill(Color.borderSubtle)
            .frame(height: 1)
            .padding(.horizontal, Spacing.xl)
            .accessibilityHidden(true)
    }

    func settingsSection(
        label: String,
        @ViewBuilder content: () -> some View
    ) -> some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text(label)
                .font(.sectionLabel)
                .foregroundStyle(Color.textTertiary)
                .tracking(LetterSpacing.sectionLabel)

            VStack(spacing: 0) {
                content()
            }
            .background(Color.bgSurface)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.lg)
                    .strokeBorder(Color.borderSubtle, lineWidth: 1)
            )
        }
    }

    // MARK: - CloudKit

    private static let cloudKitContainer = CKContainer(
        identifier: "iCloud.com.alexislours.yours"
    )

    private func refreshCloudKitStatus() async {
        do {
            cloudKitStatus = try await Self.cloudKitContainer.accountStatus()
        } catch {
            cloudKitStatus = .couldNotDetermine
        }
    }

    func settingsRow(
        icon: String,
        iconColor: Color,
        iconBackground: Color,
        title: String,
        titleColor: Color = Color.textPrimary,
        subtitle: String? = nil,
        subtitleColor: Color = Color.textTertiary,
        @ViewBuilder trailing: () -> some View
    ) -> some View {
        HStack(spacing: Spacing.md) {
            IconBadge(systemName: icon, iconColor: iconColor, backgroundColor: iconBackground)

            if let subtitle {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.bodyDefault)
                        .fontWeight(.medium)
                        .foregroundStyle(titleColor)

                    Text(subtitle)
                        .font(.bodySmall)
                        .foregroundStyle(subtitleColor)
                }
            } else {
                Text(title)
                    .font(.bodyDefault)
                    .fontWeight(.medium)
                    .foregroundStyle(titleColor)
            }

            Spacer()

            trailing()
        }
        .padding(.horizontal, Spacing.xl)
        .padding(.vertical, Spacing.lg)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
    }
}

struct ShareFile: Identifiable {
    let id = UUID()
    let url: URL
}

private struct ActivityShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context _: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_: UIActivityViewController, context _: Context) {}
}

#Preview {
    NavigationStack {
        SettingsView()
    }
    .modelContainer(for: Person.self, inMemory: true)
}
