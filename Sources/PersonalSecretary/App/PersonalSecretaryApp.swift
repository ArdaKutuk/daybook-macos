import OSLog
import SwiftData
import SwiftUI

let appLog = Logger(subsystem: "com.daybook.PersonalSecretary", category: "startup")

@main
struct PersonalSecretaryApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    private let modelContainer: ModelContainer
    private let services = ServiceContainer()
    @State private var appState = AppState()

    init() {
        appLog.notice("Application starting")
        let schema = Schema([
            TaskItem.self, Note.self, Routine.self, RoutineCompletion.self,
            FocusSession.self, LocalEvent.self, FileShortcut.self
        ])
        modelContainer = Self.makeContainer(schema: schema)
        appDelegate.modelContext = modelContainer.mainContext
        appDelegate.services = services
        appLog.notice("Main UI initialized")
    }

    /// Opens the on-disk store, falling back to an in-memory store if it can't
    /// be read. The existing file is never deleted or rewritten — a bad load is
    /// reported and the app launches read-only-ish rather than aborting, so the
    /// user can still reach Settings > Data and export/repair.
    private static func makeContainer(schema: Schema) -> ModelContainer {
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            let container = try ModelContainer(for: schema, configurations: [configuration])
            appLog.notice("Database initialized at \(configuration.url.path, privacy: .public)")
            return container
        } catch {
            appLog.fault("Database initialization failed: \(error.localizedDescription, privacy: .public)")
        }
        do {
            let fallback = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: schema, configurations: [fallback])
            appLog.warning("Running with a temporary in-memory store; on-disk data was left untouched")
            return container
        } catch {
            appLog.fault("In-memory store failed: \(error.localizedDescription, privacy: .public)")
            fatalError("Couldn't create any data store: \(error.localizedDescription)")
        }
    }

    var body: some Scene {
        WindowGroup(id: "main") {
            AppRootContainer()
                .environment(appState)
                .environment(services.calendarService)
                .environment(services.notificationService)
                .environment(services.launchAtLoginService)
                .environment(services.focusTimerManager)
                .frame(minWidth: DT.Size.minWindowWidth, minHeight: DT.Size.minWindowHeight)
        }
        .modelContainer(modelContainer)
        .windowResizability(.contentSize)
        .commands {
            AppCommands(appState: appState)
        }

        MenuBarExtra {
            MenuBarPopoverView()
                .environment(appState)
                .environment(services.calendarService)
                .modelContainer(modelContainer)
        } label: {
            Image(systemName: "sun.horizon")
        }
        .menuBarExtraStyle(.window)
    }
}

/// Gates the main UI behind first-launch Onboarding.
struct AppRootContainer: View {
    @AppStorage(SettingsKeys.hasCompletedOnboarding) private var hasCompletedOnboarding = false
    @AppStorage(SettingsKeys.appearance) private var appearance = AppearanceMode.light.rawValue

    var body: some View {
        Group {
            if hasCompletedOnboarding {
                RootView()
            } else {
                OnboardingView(onFinish: { hasCompletedOnboarding = true })
            }
        }
        // The design's palette is entirely custom (no dark variant), so this
        // only affects system chrome (window titlebar, native controls) —
        // "System" lets that follow macOS, "Light" pins it to match our UI.
        .preferredColorScheme(AppearanceMode(rawValue: appearance) == .system ? nil : .light)
    }
}
