import Foundation
import Observation
import ServiceManagement

/// Wraps `SMAppService.mainApp` (the modern replacement for the old
/// `SMLoginItemSetEnabled` / helper-app approach) for the Settings > General
/// "Launch at Login" toggle.
@Observable
final class LaunchAtLoginService {
    private(set) var isEnabled: Bool
    private(set) var lastError: String?

    init() {
        isEnabled = SMAppService.mainApp.status == .enabled
    }

    func refresh() {
        isEnabled = SMAppService.mainApp.status == .enabled
    }

    func setEnabled(_ enabled: Bool) {
        do {
            if enabled {
                if SMAppService.mainApp.status != .enabled {
                    try SMAppService.mainApp.register()
                }
            } else {
                if SMAppService.mainApp.status == .enabled {
                    try SMAppService.mainApp.unregister()
                }
            }
            lastError = nil
        } catch {
            lastError = "Couldn't update Launch at Login: \(error.localizedDescription)"
        }
        refresh()
    }
}
