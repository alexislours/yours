import CloudKit
import SwiftData
import SwiftUI
import WidgetKit

@main
struct YoursApp: App {
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    @State private var containerError: String?

    #if DEBUG
        private static let isScreenshotMode = ProcessInfo.processInfo.arguments.contains("--screenshots")
        private static let isUITesting = ProcessInfo.processInfo.arguments.contains("-ui_testing")
    #endif

    private static let schema = Schema([
        Person.self, Note.self, ImportantDate.self, DateCategory.self,
        GiftIdea.self, GiftCategory.self, AskAboutItem.self,
        LikeDislikeItem.self, LikeDislikeCategory.self,
        ClothingSizeItem.self, ClothingSizeCategory.self,
        AllergyItem.self, AllergyCategory.self,
        FoodOrderItem.self, FoodOrderCategory.self,
        TheirPeopleItem.self, TheirPeopleCategory.self,
        Quirk.self, PetName.self, Dream.self,
    ])

    private static let containerResult: (container: ModelContainer, errorMessage: String?) = {
        #if DEBUG
            if isScreenshotMode || isUITesting {
                let inMemoryConfig = ModelConfiguration(
                    schema: schema,
                    isStoredInMemoryOnly: true,
                    cloudKitDatabase: .none
                )
                do {
                    return try (ModelContainer(
                        for: schema,
                        migrationPlan: YoursMigrationPlan.self,
                        configurations: [inMemoryConfig]
                    ), nil)
                } catch {
                    fatalError("Could not create in-memory ModelContainer for UI testing: \(error)")
                }
            }
        #endif

        let cloudConfig = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .automatic
        )

        do {
            return try (ModelContainer(
                for: schema,
                migrationPlan: YoursMigrationPlan.self,
                configurations: [cloudConfig]
            ), nil)
        } catch {
            let errorMessage: String
            let nsError = error as NSError
            if nsError.domain == CKError.errorDomain,
               nsError.code == CKError.notAuthenticated.rawValue
               || nsError.code == CKError.accountTemporarilyUnavailable.rawValue {
                errorMessage =
                    "iCloud sync is unavailable. Check that you're signed into iCloud in Settings."
            } else if nsError.domain == CKError.errorDomain,
                      nsError.code == CKError.quotaExceeded.rawValue {
                errorMessage =
                    "Your iCloud storage is full. Free up space in Settings > Apple Account > iCloud to sync your data."
            } else {
                errorMessage =
                    "Something went wrong loading your data. Try restarting the app or reinstalling if the issue persists."
            }
            let localConfig = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                cloudKitDatabase: .none
            )
            do {
                return try (ModelContainer(
                    for: schema,
                    migrationPlan: YoursMigrationPlan.self,
                    configurations: [localConfig]
                ), errorMessage)
            } catch {
                fatalError("Could not create ModelContainer: \(error)")
            }
        }
    }()

    init() {
        UserDefaults.standard.register(defaults: [
            UserDefaultsKeys.notificationsEnabled: true,
            UserDefaultsKeys.hapticsEnabled: true,
        ])
        _containerError = State(initialValue: Self.containerResult.errorMessage)
    }

    var body: some Scene {
        WindowGroup {
            AppRootView(
                pendingQuickActionType: appDelegate.pendingQuickActionType,
                containerError: containerError
            )
            .task {
                let context = Self.containerResult.container.mainContext
                #if DEBUG
                    if Self.isScreenshotMode {
                        MockDataSeeder.seed(modelContext: context)
                    }
                #endif
                NotificationService.shared.rescheduleAll(modelContext: context)
                appDelegate.pendingQuickActionType = nil
            }
        }
        .modelContainer(Self.containerResult.container)
    }
}

// MARK: - App Delegate

@MainActor
final class AppDelegate: NSObject, UIApplicationDelegate {
    var pendingQuickActionType: String?

    func application(
        _: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        if let shortcutItem = options.shortcutItem {
            pendingQuickActionType = shortcutItem.type
        }
        let config = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        config.delegateClass = SceneDelegate.self
        return config
    }
}

// MARK: - Scene Delegate

@MainActor
final class SceneDelegate: NSObject, UIWindowSceneDelegate {
    func windowScene(
        _: UIWindowScene,
        performActionFor shortcutItem: UIApplicationShortcutItem,
        completionHandler: @escaping @Sendable (Bool) -> Void
    ) {
        NotificationCenter.default.post(name: .quickActionTriggered, object: shortcutItem.type)
        completionHandler(true)
    }
}

// MARK: - Root routing view

struct AppRootView: View {
    @Query private var persons: [Person]
    @AppStorage(UserDefaultsKeys.appColorScheme) private var colorSchemeRaw: String = "system"
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.modelContext) private var modelContext
    @State private var deepLink: DeepLink?
    @State private var navigationPath = NavigationPath()
    let pendingQuickActionType: String?
    let containerError: String?

    private var person: Person? {
        persons.first
    }

    private var preferredColorScheme: ColorScheme? {
        switch colorSchemeRaw {
        case "light": .light
        case "dark": .dark
        default: nil
        }
    }

    var body: some View {
        Group {
            if let person {
                NavigationStack(path: $navigationPath) {
                    HomeView(
                        person: person,
                        pendingQuickActionType: pendingQuickActionType,
                        deepLink: $deepLink,
                        navigationPath: $navigationPath
                    )
                }
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .scale(scale: 0.97)),
                    removal: .opacity
                ))
            } else {
                OnboardingFlow()
                    .transition(.opacity)
            }
        }
        .animation(.motionAware(.easeInOut(duration: 0.8)), value: persons.isEmpty)
        .preferredColorScheme(preferredColorScheme)
        .onChange(of: persons.count) {
            WidgetDataService.sync(modelContext: modelContext)
        }
        .onOpenURL { url in
            deepLink = DeepLink(url: url)
        }
        .onChange(of: scenePhase) {
            if scenePhase == .active {
                if let person {
                    QuickActionService.registerShortcuts()
                    PendingGiftImportService.importPending(for: person, in: modelContext)
                } else {
                    QuickActionService.clearShortcuts()
                }
                WidgetDataService.sync(modelContext: modelContext)
            }
            if scenePhase == .background {
                WidgetDataService.sync(modelContext: modelContext)
            }
        }
        .overlay(alignment: .top) {
            if let containerError {
                ContainerErrorBanner(message: containerError)
            }
        }
    }
}

// MARK: - Container Error Banner

private struct ContainerErrorBanner: View {
    let message: String

    var body: some View {
        Label {
            Text(message)
        } icon: {
            Image(systemName: "exclamationmark.triangle.fill")
        }
        .font(.footnote)
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial)
    }
}
