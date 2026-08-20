import Carbon.HIToolbox
import Foundation

/// Registers a truly global keyboard shortcut (works even when the app isn't
/// frontmost) using the Carbon Event Manager's hotkey APIs. This is the
/// standard, entitlement-free way to do this on macOS — unlike a CGEventTap,
/// it needs no Accessibility permission.
///
/// Only one hotkey is registered at a time (Quick Capture). Cmd+K global
/// search stays a plain in-app `.keyboardShortcut`, since it only needs to
/// work while the app is frontmost.
final class GlobalHotkeyService {
    private var hotKeyRef: EventHotKeyRef?
    private var eventHandler: EventHandlerRef?
    private var handler: (() -> Void)?
    private let hotKeyID = EventHotKeyID(signature: OSType(0x4442_4B31), id: 1) // 'DBK1'

    struct KeyCombo {
        var keyCode: UInt32
        var modifiers: UInt32

        /// Default: Option + Space.
        static let quickCaptureDefault = KeyCombo(keyCode: UInt32(kVK_Space), modifiers: UInt32(optionKey))
    }

    func register(combo: KeyCombo = .quickCaptureDefault, handler: @escaping () -> Void) {
        unregister()
        self.handler = handler

        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: OSType(kEventHotKeyPressed))
        InstallEventHandler(GetApplicationEventTarget(), { _, eventRef, userData in
            guard let userData, let eventRef else { return noErr }
            let service = Unmanaged<GlobalHotkeyService>.fromOpaque(userData).takeUnretainedValue()
            var receivedID = EventHotKeyID()
            GetEventParameter(eventRef, EventParamName(kEventParamDirectObject), EventParamType(typeEventHotKeyID), nil, MemoryLayout<EventHotKeyID>.size, nil, &receivedID)
            if receivedID.id == service.hotKeyID.id {
                service.handler?()
            }
            return noErr
        }, 1, &eventType, Unmanaged.passUnretained(self).toOpaque(), &eventHandler)

        RegisterEventHotKey(combo.keyCode, combo.modifiers, hotKeyID, GetApplicationEventTarget(), 0, &hotKeyRef)
    }

    func unregister() {
        if let hotKeyRef { UnregisterEventHotKey(hotKeyRef) }
        hotKeyRef = nil
        if let eventHandler { RemoveEventHandler(eventHandler) }
        eventHandler = nil
    }

    deinit {
        unregister()
    }
}
