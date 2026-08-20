import AppKit
import SwiftData
import SwiftUI

/// Hosts the Quick Capture UI in a borderless, floating `NSPanel` so
/// Option+Space can summon it even when Daybook isn't the frontmost app —
/// something a plain SwiftUI sheet inside the main window can't do.
@MainActor
final class QuickCapturePanelController {
    private var panel: NSPanel?
    private let modelContext: ModelContext
    private let notificationService: NotificationService

    init(modelContext: ModelContext, notificationService: NotificationService) {
        self.modelContext = modelContext
        self.notificationService = notificationService
    }

    func toggle() {
        if let panel, panel.isVisible {
            close()
        } else {
            show()
        }
    }

    func show() {
        let panel = panel ?? makePanel()
        self.panel = panel
        panel.center()
        // Bias toward the top of the screen, echoing the prototype's
        // `padding-top:120px` overlay placement.
        if let screenFrame = NSScreen.main?.visibleFrame {
            let x = screenFrame.midX - panel.frame.width / 2
            let y = screenFrame.maxY - panel.frame.height - 140
            panel.setFrameOrigin(NSPoint(x: x, y: y))
        }
        NSApp.activate(ignoringOtherApps: true)
        panel.makeKeyAndOrderFront(nil)
    }

    func close() {
        panel?.orderOut(nil)
    }

    private func makePanel() -> NSPanel {
        let view = QuickCaptureView(
            context: modelContext,
            notificationService: notificationService,
            onDismiss: { [weak self] in self?.close() }
        )
        let hosting = NSHostingController(rootView: view)
        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 420, height: 230),
            styleMask: [.titled, .fullSizeContentView, .nonactivatingPanel, .closable],
            backing: .buffered,
            defer: false
        )
        panel.titleVisibility = .hidden
        panel.titlebarAppearsTransparent = true
        panel.isMovableByWindowBackground = true
        panel.level = .floating
        panel.hidesOnDeactivate = false
        panel.contentViewController = hosting
        panel.isReleasedWhenClosed = false
        panel.standardWindowButton(.closeButton)?.isHidden = true
        panel.standardWindowButton(.miniaturizeButton)?.isHidden = true
        panel.standardWindowButton(.zoomButton)?.isHidden = true
        return panel
    }
}
