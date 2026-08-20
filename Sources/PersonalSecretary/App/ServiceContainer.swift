import Foundation

/// Simple dependency container: one instance of each service, created once
/// at launch and threaded through the environment. Avoids singletons while
/// still giving every View/ViewModel a single shared source of truth for
/// calendar/notification/focus/launch-at-login state.
@MainActor
final class ServiceContainer {
    let calendarService = CalendarService()
    let notificationService: NotificationService
    let launchAtLoginService = LaunchAtLoginService()
    let globalHotkeyService = GlobalHotkeyService()
    let focusTimerManager: FocusTimerManager

    init() {
        let notifications = NotificationService()
        self.notificationService = notifications
        self.focusTimerManager = FocusTimerManager(notificationService: notifications)
    }
}
