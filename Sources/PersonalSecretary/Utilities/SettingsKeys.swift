import Foundation

/// Central registry of `UserDefaults` / `@AppStorage` keys so Views (which use
/// `@AppStorage` for reactivity) and Services (which read `UserDefaults`
/// directly, outside of SwiftUI's environment) never drift apart.
enum SettingsKeys {
    static let hasCompletedOnboarding = "hasCompletedOnboarding"
    static let launchAtLogin = "launchAtLogin"
    static let startPage = "startPage"
    static let dateFormat = "dateFormat"
    static let firstDayOfWeek = "firstDayOfWeek"
    static let appearance = "appearance"
    static let focusDurationMinutes = "focusDurationMinutes"
    static let breakDurationMinutes = "breakDurationMinutes"
    static let notifTasksEnabled = "notifTasksEnabled"
    static let notifRoutinesEnabled = "notifRoutinesEnabled"
    static let notifFocusEnabled = "notifFocusEnabled"
    static let quickCaptureShortcut = "quickCaptureShortcut"
}

/// Non-View access to the same settings backed by `SettingsKeys`, for use in
/// Services and ViewModels that live outside SwiftUI's `@AppStorage` context.
enum AppSettings {
    private static var defaults: UserDefaults { .standard }

    static var notifTasksEnabled: Bool {
        defaults.object(forKey: SettingsKeys.notifTasksEnabled) as? Bool ?? true
    }
    static var notifRoutinesEnabled: Bool {
        defaults.object(forKey: SettingsKeys.notifRoutinesEnabled) as? Bool ?? true
    }
    static var notifFocusEnabled: Bool {
        defaults.object(forKey: SettingsKeys.notifFocusEnabled) as? Bool ?? false
    }
    static var focusDurationMinutes: Int {
        let value = defaults.integer(forKey: SettingsKeys.focusDurationMinutes)
        return value == 0 ? 25 : value
    }
    static var breakDurationMinutes: Int {
        let value = defaults.integer(forKey: SettingsKeys.breakDurationMinutes)
        return value == 0 ? 5 : value
    }
    static var dateFormat: AppDateFormat {
        AppDateFormat(rawValue: defaults.string(forKey: SettingsKeys.dateFormat) ?? "") ?? .mdy
    }
    static var firstDayOfWeek: FirstWeekday {
        FirstWeekday(rawValue: defaults.string(forKey: SettingsKeys.firstDayOfWeek) ?? "") ?? .sunday
    }
    static var startPage: StartPage {
        StartPage(rawValue: defaults.string(forKey: SettingsKeys.startPage) ?? "") ?? .today
    }
}
