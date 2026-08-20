import SwiftUI

/// Native `Commands` for the keyboard shortcuts the spec calls out: ⌘N,
/// ⌘⇧N, ⌘K, ⌘,, ⌘1/2/3. These only fire while the app is frontmost — the
/// one truly global shortcut (⌥Space, Quick Capture) is handled separately
/// by `GlobalHotkeyService`.
struct AppCommands: Commands {
    var appState: AppState

    var body: some Commands {
        CommandGroup(replacing: .newItem) {
            Button("New Task") { appState.openNewTask() }
                .keyboardShortcut("n", modifiers: .command)
            Button("New Note") { appState.newNoteRequestCount += 1; appState.navigate(to: .notes) }
                .keyboardShortcut("n", modifiers: [.command, .shift])
        }
        CommandGroup(after: .toolbar) {
            Button("Search") { appState.showGlobalSearch = true }
                .keyboardShortcut("k", modifiers: .command)
        }
        CommandGroup(replacing: .appSettings) {
            Button("Settings…") { appState.navigate(to: .settings) }
                .keyboardShortcut(",", modifiers: .command)
        }
        CommandMenu("Go") {
            Button("Today") { appState.navigate(to: .today) }.keyboardShortcut("1", modifiers: .command)
            Button("Tasks") { appState.navigate(to: .tasks) }.keyboardShortcut("2", modifiers: .command)
            Button("Calendar") { appState.navigate(to: .calendar) }.keyboardShortcut("3", modifiers: .command)
        }
    }
}
