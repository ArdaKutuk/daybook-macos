import Foundation

enum Priority: String, Codable, CaseIterable, Identifiable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"

    var id: String { rawValue }

    var sortOrder: Int {
        switch self {
        case .high: return 0
        case .medium: return 1
        case .low: return 2
        }
    }
}

enum TaskCategory: String, Codable, CaseIterable, Identifiable {
    case work = "Work"
    case personal = "Personal"
    case health = "Health"
    case study = "Study"
    case home = "Home"

    var id: String { rawValue }
}

enum TaskStatus: String, Codable {
    case pending
    case completed
}

enum RecurrenceRule: String, Codable, CaseIterable, Identifiable {
    case none = "None"
    case daily = "Daily"
    case weekly = "Weekly"

    var id: String { rawValue }
}

enum ReminderOffset: String, Codable, CaseIterable, Identifiable {
    case none = "None"
    case atTime = "At time"
    case fifteenMinBefore = "15 min before"

    var id: String { rawValue }

    var minutesBefore: Int? {
        switch self {
        case .none: return nil
        case .atTime: return 0
        case .fifteenMinBefore: return 15
        }
    }
}

enum RoutineFrequency: String, Codable, CaseIterable, Identifiable {
    case daily = "Daily"
    case selectedDays = "Selected Days"
    case weekly = "Weekly"

    var id: String { rawValue }
}

enum Weekday: Int, Codable, CaseIterable, Identifiable {
    case monday = 2, tuesday = 3, wednesday = 4, thursday = 5, friday = 6, saturday = 7, sunday = 1

    var id: Int { rawValue }

    /// Matches Calendar.Component.weekday (1 = Sunday ... 7 = Saturday).
    var calendarWeekday: Int { rawValue }

    var shortLabel: String {
        switch self {
        case .monday: return "Mon"
        case .tuesday: return "Tue"
        case .wednesday: return "Wed"
        case .thursday: return "Thu"
        case .friday: return "Fri"
        case .saturday: return "Sat"
        case .sunday: return "Sun"
        }
    }

    /// Monday-first ordering, matching the design's day picker.
    static var orderedMondayFirst: [Weekday] {
        [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
    }
}

enum FileShortcutType: String, Codable {
    case file
    case folder
}

enum StartPage: String, Codable, CaseIterable, Identifiable {
    case today = "Today"
    case tasks = "Tasks"
    case calendar = "Calendar"

    var id: String { rawValue }
}

enum AppDateFormat: String, Codable, CaseIterable, Identifiable {
    case mdy = "MM/DD/YYYY"
    case dmy = "DD/MM/YYYY"
    case iso = "YYYY-MM-DD"

    var id: String { rawValue }

    var swiftFormat: String {
        switch self {
        case .mdy: return "MM/dd/yyyy"
        case .dmy: return "dd/MM/yyyy"
        case .iso: return "yyyy-MM-dd"
        }
    }
}

enum FirstWeekday: String, Codable, CaseIterable, Identifiable {
    case sunday = "Sunday"
    case monday = "Monday"

    var id: String { rawValue }

    /// Matches Calendar.firstWeekday (1 = Sunday, 2 = Monday).
    var calendarValue: Int { self == .sunday ? 1 : 2 }
}

enum AppearanceMode: String, Codable, CaseIterable, Identifiable {
    case system = "System"
    case light = "Light"

    var id: String { rawValue }
}

enum FocusPreset: String, Codable, CaseIterable, Identifiable {
    case classic = "25 / 5"
    case long = "50 / 10"
    case custom = "Custom"

    var id: String { rawValue }
}
