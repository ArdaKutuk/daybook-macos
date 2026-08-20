import SwiftUI

enum CalendarViewMode: String, CaseIterable, Identifiable {
    case month = "Month", week = "Week", day = "Day"
    var id: String { rawValue }
}

struct CalendarChip: Identifiable {
    enum Kind { case localEvent, externalEvent, task }
    let id: String
    let label: String
    let background: Color
    let foreground: Color
    let kind: Kind
}

struct CalendarDayCell: Identifiable {
    let id = UUID()
    let date: Date?
    let isToday: Bool
    let chips: [CalendarChip]
}

/// Pure calendar-grid math, independent of the View so month rollover /
/// first-weekday handling can be reasoned about (and tested) in isolation.
enum CalendarViewModel {

    static func weekdayLabels(firstWeekday: FirstWeekday, calendar: Calendar = .current) -> [String] {
        let all = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        let startIndex = firstWeekday.calendarValue - 1
        return Array(all[startIndex...] + all[..<startIndex])
    }

    /// Returns a grid of cells (multiple of 7) covering the full month, with
    /// `nil` dates as invisible leading/trailing padding.
    static func monthCells(monthAnchor: Date, firstWeekday: FirstWeekday, calendar rawCalendar: Calendar = .current) -> [Date?] {
        var calendar = rawCalendar
        calendar.firstWeekday = firstWeekday.calendarValue

        guard let monthInterval = calendar.dateInterval(of: .month, for: monthAnchor) else { return [] }
        let firstOfMonth = monthInterval.start
        let daysInMonth = calendar.range(of: .day, in: .month, for: monthAnchor)?.count ?? 30

        let firstWeekdayOfMonth = calendar.component(.weekday, from: firstOfMonth)
        let leadingEmpty = (firstWeekdayOfMonth - calendar.firstWeekday + 7) % 7

        var cells: [Date?] = Array(repeating: nil, count: leadingEmpty)
        for day in 0..<daysInMonth {
            if let date = calendar.date(byAdding: .day, value: day, to: firstOfMonth) {
                cells.append(date)
            }
        }
        while cells.count % 7 != 0 { cells.append(nil) }
        return cells
    }

    static func chips(
        for date: Date,
        localEvents: [LocalEvent],
        externalEvents: [ExternalEvent],
        tasks: [TaskItem],
        calendar: Calendar = .current
    ) -> [CalendarChip] {
        var chips: [CalendarChip] = []
        for event in localEvents where calendar.isDate(event.startDate, inSameDayAs: date) {
            chips.append(CalendarChip(id: "local-\(event.id)", label: event.title, background: DT.Color.lavenderBackground, foreground: DT.Color.lavenderText, kind: .localEvent))
        }
        for event in externalEvents where calendar.isDate(event.startDate, inSameDayAs: date) {
            chips.append(CalendarChip(id: "ext-\(event.id)", label: event.title, background: DT.Color.accentSoftBackground, foreground: DT.Color.accentSoftText, kind: .externalEvent))
        }
        for task in tasks where (task.dueDate.map { calendar.isDate($0, inSameDayAs: date) }) ?? false {
            chips.append(CalendarChip(id: "task-\(task.id)", label: task.title, background: DT.Color.orangeBackground, foreground: DT.Color.orangeText, kind: .task))
        }
        return chips
    }

    /// Hour rows (8:00–18:00) for the Day view, echoing the prototype.
    static func dayHours() -> [Int] { Array(8...18) }

    static func hourLabel(_ hour: Int) -> String {
        let h = hour % 12 == 0 ? 12 : hour % 12
        return "\(h)\(hour < 12 ? "AM" : "PM")"
    }
}
