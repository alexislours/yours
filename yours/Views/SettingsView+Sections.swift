import SwiftUI
import UserNotifications

// MARK: - Settings Sections

extension SettingsView {
    var person: Person? {
        persons.first
    }

    var profileSection: some View {
        Button { showProfileEditor = true } label: {
            HStack(spacing: Spacing.lg) {
                if let person {
                    AvatarView(
                        name: person.name,
                        size: 48,
                        image: avatarImage
                    )

                    VStack(alignment: .leading, spacing: 2) {
                        Text(person.name)
                            .font(.heading3)
                            .foregroundStyle(Color.textPrimary)

                        Text(person.durationDescription)
                            .font(.caption)
                            .foregroundStyle(Color.textTertiary)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.custom(FontFamily.ui, size: 12, relativeTo: .caption).weight(.medium))
                    .foregroundStyle(Color.textTertiary)
                    .accessibilityHidden(true)
            }
            .padding(.horizontal, Spacing.xl)
            .padding(.vertical, Spacing.lg)
            .background(Color.bgSurface)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.lg)
                    .strokeBorder(Color.borderSubtle, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            String(
                localized: "Edit profile",
                comment: "Accessibility: edit profile button in settings"
            )
        )
        .task(id: person?.photoData) {
            guard let data = person?.photoData else {
                avatarImage = nil
                return
            }
            avatarImage = await decodeImage(from: data)
        }
    }

    // MARK: - Appearance

    var themeDisplayName: String {
        switch colorSchemeRaw {
        case "light": String(localized: "Light", comment: "Settings: light theme option")
        case "dark": String(localized: "Dark", comment: "Settings: dark theme option")
        default: String(localized: "System", comment: "Settings: system theme option, follows device setting")
        }
    }

    var currencyDisplayName: String {
        Locale.current.localizedString(forCurrencyCode: currencyCode) ?? currencyCode
    }

    var appearanceSection: some View {
        settingsSection(label: String(localized: "APPEARANCE", comment: "Settings: appearance section header")) {
            NavigationLink(destination: ThemePickerView(colorSchemeRaw: $colorSchemeRaw)) {
                settingsRow(
                    icon: "circle.lefthalf.filled",
                    iconColor: Color.accentSecondary,
                    iconBackground: Color.accentSecondarySoft,
                    title: String(localized: "Theme", comment: "Settings: theme row title")
                ) {
                    HStack(spacing: Spacing.xs) {
                        Text(themeDisplayName)
                            .font(.bodySmall)
                            .foregroundStyle(Color.textSecondary)
                        Image(systemName: "chevron.right")
                            .font(.custom(FontFamily.ui, size: 12, relativeTo: .caption).weight(.medium))
                            .foregroundStyle(Color.textTertiary)
                            .accessibilityHidden(true)
                    }
                }
            }
            .buttonStyle(.plain)

            rowDivider

            NavigationLink(destination: CurrencyPickerView(currencyCode: $currencyCode)) {
                settingsRow(
                    icon: "banknote",
                    iconColor: Color.accentSecondary,
                    iconBackground: Color.accentSecondarySoft,
                    title: String(localized: "Currency", comment: "Settings: currency row title")
                ) {
                    HStack(spacing: Spacing.xs) {
                        Text(currencyDisplayName)
                            .font(.bodySmall)
                            .foregroundStyle(Color.textSecondary)
                        Image(systemName: "chevron.right")
                            .font(.custom(FontFamily.ui, size: 12, relativeTo: .caption).weight(.medium))
                            .foregroundStyle(Color.textTertiary)
                            .accessibilityHidden(true)
                    }
                }
            }
            .buttonStyle(.plain)

            rowDivider

            settingsRow(
                icon: "hand.tap",
                iconColor: Color.accentSecondary,
                iconBackground: Color.accentSecondarySoft,
                title: String(localized: "Haptics", comment: "Settings: haptic feedback toggle row title"),
                subtitle: String(localized: "Tactile feedback on interactions", comment: "Settings: haptic feedback row subtitle")
            ) {
                Toggle(isOn: $hapticsEnabled) {}
                    .labelsHidden()
                    .tint(Color.accentPrimary)
            }
        }
    }

    // MARK: - Notifications

    var notificationTimeDate: Binding<Date> {
        Binding(
            get: {
                var comps = DateComponents()
                comps.hour = notificationHour
                comps.minute = notificationMinute
                return Calendar.current.date(from: comps) ?? .now
            },
            set: { newValue in
                let comps = Calendar.current.dateComponents([.hour, .minute], from: newValue)
                notificationHour = comps.hour ?? 9
                notificationMinute = comps.minute ?? 0
                notificationTimeSet = true
                NotificationService.shared.rescheduleAll(modelContext: modelContext)
            }
        )
    }

    var notificationsSection: some View {
        settingsSection(label: String(localized: "NOTIFICATIONS", comment: "Settings: notifications section header")) {
            settingsRow(
                icon: "bell.fill",
                iconColor: Color.accentPrimary,
                iconBackground: Color.accentPrimarySoft,
                title: String(localized: "Notifications", comment: "Settings: notifications toggle row title"),
                subtitle: String(localized: "Reminders for important dates", comment: "Settings: notifications row subtitle")
            ) {
                Toggle(isOn: $notificationsEnabled) {}
                    .labelsHidden()
                    .tint(Color.accentPrimary)
            }
            .onChange(of: notificationsEnabled) { _, enabled in
                if enabled {
                    NotificationService.shared.rescheduleAll(modelContext: modelContext)
                } else {
                    UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                }
            }

            if notificationsEnabled {
                rowDivider
                    .transition(.opacity)

                settingsRow(
                    icon: "clock.fill",
                    iconColor: Color.accentSecondary,
                    iconBackground: Color.accentSecondarySoft,
                    title: String(localized: "Reminder time", comment: "Settings: time picker row title"),
                    subtitle: String(localized: "When you get notified", comment: "Settings: time picker row subtitle")
                ) {
                    DatePicker(
                        selection: notificationTimeDate,
                        displayedComponents: .hourAndMinute
                    ) {}
                        .labelsHidden()
                        .tint(Color.accentPrimary)
                }
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.motionAware(.spring(response: 0.3, dampingFraction: 0.85)), value: notificationsEnabled)
    }

    // MARK: - Sync

    var syncSection: some View {
        settingsSection(label: String(localized: "SYNC", comment: "Settings: sync section header")) {
            settingsRow(
                icon: cloudKitStatusIcon,
                iconColor: cloudKitStatusColor,
                iconBackground: cloudKitStatusColor.opacity(Opacity.iconBackground),
                title: String(localized: "iCloud Sync", comment: "Settings: iCloud sync row title"),
                subtitle: cloudKitStatusSubtitle,
                subtitleColor: cloudKitStatusColor
            ) {
                Text(cloudKitStatusLabel)
                    .font(.bodySmall)
                    .fontWeight(.semibold)
                    .padding(.horizontal, Spacing.sm)
                    .padding(.vertical, Spacing.xxs)
                    .background(cloudKitStatusColor.opacity(Opacity.iconBackground))
                    .foregroundStyle(cloudKitStatusColor)
                    .clipShape(Capsule())
            }
        }
    }

    // MARK: - Data

    var dataSection: some View {
        settingsSection(label: String(localized: "DATA", comment: "Settings: data section header")) {
            Button(action: { showImporter = true }, label: {
                settingsRow(
                    icon: "arrow.down.to.line",
                    iconColor: Color.accentSecondary,
                    iconBackground: Color.accentSecondarySoft,
                    title: String(localized: "Import Data", comment: "Settings: import data row title")
                ) {
                    Image(systemName: "chevron.right")
                        .font(.custom(FontFamily.ui, size: 12, relativeTo: .caption).weight(.medium))
                        .foregroundStyle(Color.textTertiary)
                        .accessibilityHidden(true)
                }
            })
            .buttonStyle(.plain)

            rowDivider

            Button(action: { prepareExport() }, label: {
                settingsRow(
                    icon: "arrow.up.to.line",
                    iconColor: Color.accentSecondary,
                    iconBackground: Color.accentSecondarySoft,
                    title: String(localized: "Export Data", comment: "Settings: export data row title")
                ) {
                    Image(systemName: "chevron.right")
                        .font(.custom(FontFamily.ui, size: 12, relativeTo: .caption).weight(.medium))
                        .foregroundStyle(Color.textTertiary)
                        .accessibilityHidden(true)
                }
            })
            .buttonStyle(.plain)

            rowDivider

            Button(action: { showStartOverAlert = true }, label: {
                settingsRow(
                    icon: "trash",
                    iconColor: Color.error,
                    iconBackground: Color.errorSoft,
                    title: String(localized: "Start Over", comment: "Settings: destructive row to delete all data"),
                    titleColor: Color.error,
                    subtitle: String(localized: "Delete all data and reset", comment: "Settings: subtitle for start-over row")
                ) {
                    Image(systemName: "chevron.right")
                        .font(.custom(FontFamily.ui, size: 12, relativeTo: .caption).weight(.medium))
                        .foregroundStyle(Color.textTertiary)
                        .accessibilityHidden(true)
                }
            })
            .buttonStyle(.plain)
        }
    }

    // MARK: - About

    var aboutSection: some View {
        settingsSection(label: String(localized: "ABOUT", comment: "Settings: about section header")) {
            if let url = URL(string: "https://github.com/alexislours/yours") {
                Link(destination: url) {
                    HStack(spacing: Spacing.md) {
                        RoundedRectangle(cornerRadius: CornerRadius.sm)
                            .fill(Color.accentSecondarySoft)
                            .frame(width: 36, height: 36)
                            .overlay(
                                Image("GitHubIcon")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 18, height: 18)
                                    .foregroundStyle(Color.accentSecondary)
                            )
                            .accessibilityHidden(true)

                        Text(String(localized: "Source Code", comment: "Settings: GitHub source code link"))
                            .font(.bodyDefault)
                            .fontWeight(.medium)
                            .foregroundStyle(Color.textPrimary)

                        Spacer()

                        Image(systemName: "arrow.up.right")
                            .font(.custom(FontFamily.ui, size: 12, relativeTo: .caption).weight(.medium))
                            .foregroundStyle(Color.textTertiary)
                            .accessibilityHidden(true)
                    }
                    .padding(.horizontal, Spacing.xl)
                    .padding(.vertical, Spacing.lg)
                    .contentShape(Rectangle())
                    .accessibilityElement(children: .combine)
                }
                .buttonStyle(.plain)
            }

            rowDivider

            Button(action: handleVersionTap) {
                settingsRow(
                    icon: "heart.fill",
                    iconColor: Color.accentRose,
                    iconBackground: Color.accentRoseSoft,
                    title: String(localized: "Version", comment: "Settings: version row title")
                ) {
                    Text(appVersion)
                        .font(.bodySmall)
                        .foregroundStyle(Color.textSecondary)
                }
            }
            .buttonStyle(.plain)

            if devModeEnabled {
                rowDivider

                settingsRow(
                    icon: "hammer.fill",
                    iconColor: Color.accentSecondary,
                    iconBackground: Color.accentSecondarySoft,
                    title: String(localized: "Developer Mode", comment: "Settings: developer mode toggle row title"),
                    subtitle: String(localized: "Enabled", comment: "Settings: developer mode subtitle when active")
                ) {
                    Toggle(isOn: $devModeEnabled) {}
                        .labelsHidden()
                        .tint(Color.accentPrimary)
                }
            }
        }
    }

    // MARK: - Developer

    var developerSection: some View {
        settingsSection(label: String(localized: "DEVELOPER", comment: "Settings: developer section header")) {
            Button(action: { showResetPostOnboardingAlert = true }, label: {
                settingsRow(
                    icon: "arrow.counterclockwise",
                    iconColor: Color.accentSecondary,
                    iconBackground: Color.accentSecondarySoft,
                    title: String(localized: "Reset Post-Onboarding", comment: "Settings: developer row to reset post-onboarding data"),
                    subtitle: String(localized: "Keep onboarding data, clear the rest",
                                     comment: "Settings: subtitle for reset post-onboarding row")
                ) {
                    Image(systemName: "chevron.right")
                        .font(.custom(FontFamily.ui, size: 12, relativeTo: .caption).weight(.medium))
                        .foregroundStyle(Color.textTertiary)
                        .accessibilityHidden(true)
                }
            })
            .buttonStyle(.plain)

            rowDivider

            Button(action: sendTestNotification) {
                settingsRow(
                    icon: "bell.badge",
                    iconColor: Color.accentPrimary,
                    iconBackground: Color.accentPrimarySoft,
                    title: String(localized: "Test Notification", comment: "Settings: developer row to send a test notification"),
                    subtitle: String(localized: "Send a notification in 3 seconds", comment: "Settings: subtitle for test notification row")
                ) {
                    Image(systemName: "chevron.right")
                        .font(.custom(FontFamily.ui, size: 12, relativeTo: .caption).weight(.medium))
                        .foregroundStyle(Color.textTertiary)
                        .accessibilityHidden(true)
                }
            }
            .buttonStyle(.plain)
        }
    }
}
