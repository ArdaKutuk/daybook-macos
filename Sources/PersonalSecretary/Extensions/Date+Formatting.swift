import Foundation

extension Date {
    func isSameDay(as other: Date, calendar: Calendar = .current) -> Bool {
        calendar.isDate(self, inSameDayAs: other)
    }

    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    func adding(days: Int, calendar: Calendar = .current) -> Date {
        calendar.date(byAdding: .day, value: days, to: self) ?? self
    }

    /// e.g. "07:00"
    var timeHHmm: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: self)
    }

    /// Formats using the app's configured date format (Settings > General).
    func formatted(using appFormat: AppDateFormat) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = appFormat.swiftFormat
        return formatter.string(from: self)
    }

    /// "2h ago", "Yesterday", "5 days ago" style relative label used for Notes.
    var relativeShortLabel: String {
        let calendar = Calendar.current
        let now = Date.now
        let seconds = now.timeIntervalSince(self)
        if seconds < 60 { return "Just now" }
        if seconds < 3600 {
            let minutes = Int(seconds / 60)
            return "\(minutes)m ago"
        }
        if calendar.isDateInToday(self) {
            let hours = Int(seconds / 3600)
            return "\(hours)h ago"
        }
        if calendar.isDateInYesterday(self) { return "Yesterday" }
        let days = calendar.dateComponents([.day], from: calendar.startOfDay(for: self), to: calendar.startOfDay(for: now)).day ?? 0
        if days < 7 { return "\(days) days ago" }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: self)
    }

    /// Weekday label, e.g. "Wednesday".
    var weekdayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: self)
    }

    var monthDayLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d"
        return formatter.string(from: self)
    }

    var monthYearLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: self)
    }
}

enum Greeting {
    static func forCurrentTime(date: Date = .now, calendar: Calendar = .current) -> String {
        let hour = calendar.component(.hour, from: date)
        switch hour {
        case 0..<12: return "Good Morning"
        case 12..<18: return "Good Afternoon"
        default: return "Good Evening"
        }
    }
}
