import SwiftData
import SwiftUI

@main
struct PersonalSecretaryApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    private let modelContainer: ModelContainer
    private let services = ServiceContainer()
    @State private var appState = AppState()

    init() {
        let schema = Schema([
            TaskItem.self, Note.self, Routine.self, RoutineCompletion.self,
            FocusSession.self, LocalEvent.self, FileShortcut.self
        ])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            modelContainer = try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Couldn't create the on-device data store: \(error.localizedDescription)")
        }
        appDelegate.modelContext = modelContainer.mainContext
        appDelegate.services = services
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
