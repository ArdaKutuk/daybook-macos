import Foundation
import Observation

/// Ephemeral, in-memory UI state shared across the app (current section,
/// open sheets/modals). Deliberately holds no persisted data — that all
/// lives in SwiftData — so this can stay simple and view-agnostic.
@Observable
@MainActor
final class AppState {
    var selectedSection: AppSection

    var showNewTaskSheet = false
    var showRoutineSheet = false
    var showQuickCapture = false
    var showGlobalSearch = false

    var selectedNoteID: UUID?
    var selectedEventID: UUID?
    /// Distinguishes a locally-created `LocalEvent` from an EventKit
    /// `ExternalEvent` so the Calendar detail panel knows which store to read.
    var selectedExternalEventID: String?

    /// Prefills the New Task sheet's title, used by Quick Capture and Search.
    var pendingTaskTitle: String = ""

    /// Incremented to signal "create a new note now" (⌘⇧N) — NotesView
    /// observes this rather than AppState owning Note creation directly.
    var newNoteRequestCount = 0

    init() {
        selectedSection = AppSettings.startPage.asAppSection
    }

    func navigate(to section: AppSection) {
        selectedSection = section
        showGlobalSearch = false
    }

    func openNewTask(prefilledTitle: String = "") {
        pendingTaskTitle = prefilledTitle
        showNewTaskSheet = true
    }

    func closeAllOverlays() {
        showGlobalSearch = false
        showQuickCapture = false
        showNewTaskSheet = false
        showRoutineSheet = false
    }
}

private extension StartPage {
    var asAppSection: AppSection {
        switch self {
        case .today: return .today
        case .tasks: return .tasks
        case .calendar: return .calendar
        }
    }
}
