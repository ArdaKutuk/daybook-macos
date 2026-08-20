import AppKit
import SwiftData

/// Owns the pieces that don't fit neatly into SwiftUI's `App`/`Scene` model:
/// the global Option+Space hotkey and the floating Quick Capture panel it
/// summons.
@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    var modelContext: ModelContext?
    var services: ServiceContainer?
    private var quickCapturePanel: QuickCapturePanelController?

    func applicationDidFinishLaunching(_ notification: Foundation.Notification) {
        guard let modelContext, let services else { return }
        quickCapturePanel = QuickCapturePanelController(
            modelContext: modelContext,
            notificationService: services.notificationService
        )
        services.globalHotkeyService.register { [weak self] in
            self?.quickCapturePanel?.toggle()
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        // Keep running so the MenuBarExtra and global hotkey stay live even
        // if the user closes the main window.
        false
    }
}
