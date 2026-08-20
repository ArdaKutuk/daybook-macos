import SwiftUI

/// The nine sidebar destinations, in the exact order/colors of the prototype.
enum AppSection: String, CaseIterable, Identifiable {
    case today = "Today"
    case tasks = "Tasks"
    case calendar = "Calendar"
    case notes = "Notes"
    case routines = "Routines"
    case focus = "Focus"
    case files = "Files"
    case overview = "Overview"
    case settings = "Settings"

    var id: String { rawValue }

    var dotColor: Color {
        switch self {
        case .today: return DT.NavDot.today
        case .tasks: return DT.NavDot.tasks
        case .calendar: return DT.NavDot.calendar
        case .notes: return DT.NavDot.notes
        case .routines: return DT.NavDot.routines
        case .focus: return DT.NavDot.focus
        case .files: return DT.NavDot.files
        case .overview: return DT.NavDot.overview
        case .settings: return DT.NavDot.settings
        }
    }

    /// Sidebar sections above the divider (Settings sits below, on its own).
    static var primary: [AppSection] { [.today, .tasks, .calendar, .notes, .routines, .focus, .files, .overview] }
}
