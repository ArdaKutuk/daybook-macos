import Foundation

/// Pure, testable computations backing the Today dashboard. Views own the
/// live `@Query` arrays (for SwiftData reactivity); this type just turns
/// those arrays into the numbers/labels the design calls for.
enum DashboardViewModel {

    static func tasksDueToday(_ tasks: [TaskItem], date: Date = .now, calendar: Calendar = .current) -> [TaskItem] {
        tasks
            .filter { ($0.dueDate.map { calendar.isDate($0, inSameDayAs: date) }) ?? false }
            .sorted { lhs, rhs in
                switch (lhs.dueTime, rhs.dueTime) {
                case let (l?, r?): return l < r
                case (nil, .some): return false
                case (.some, nil): return true
                default: return lhs.title < rhs.title
                }
            }
    }

    static func progress(tasks: [TaskItem]) -> (done: Int, total: Int, pct: Double) {
        let done = tasks.filter(\.isCompleted).count
        let total = tasks.count
        let pct = total == 0 ? 0 : Double(done) / Double(total)
        return (done, total, pct)
    }

    static func routinesScheduledToday(_ routines: [Routine], date: Date = .now, calendar: Calendar = .current) -> [Routine] {
        routines.filter { $0.isScheduled(on: date, calendar: calendar) }
    }

    static func routineProgress(_ routines: [Routine], date: Date = .now, calendar: Calendar = .current) -> (done: Int, total: Int) {
        let scheduled = routinesScheduledToday(routines, date: date, calendar: calendar)
        let day = calendar.startOfDay(for: date)
        let done = scheduled.filter { routine in
            (routine.completions ?? []).contains { $0.date.isSameDay(as: day, calendar: calendar) }
        }.count
        return (done, scheduled.count)
    }

    static func focusTotalSeconds(_ sessions: [FocusSession], date: Date = .now, calendar: Calendar = .current) -> Int {
        Int(sessions.filter { calendar.isDate($0.startDate, inSameDayAs: date) }.reduce(0) { $0 + $1.duration })
    }

    static func formattedDuration(seconds: Int) -> String {
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        return h > 0 ? "\(h)h \(m)m" : "\(m)m"
    }

    struct TomorrowSummary { let taskCount: Int; let eventCount: Int }

    static func tomorrowSummary(
        tasks: [TaskItem],
        localEvents: [LocalEvent],
        externalEvents: [ExternalEvent],
        referenceDate: Date = .now,
        calendar: Calendar = .current
    ) -> TomorrowSummary {
        let tomorrow = referenceDate.adding(days: 1, calendar: calendar)
        let taskCount = tasks.filter { ($0.dueDate.map { calendar.isDate($0, inSameDayAs: tomorrow) }) ?? false }.count
        let localCount = localEvents.filter { calendar.isDate($0.startDate, inSameDayAs: tomorrow) }.count
        let externalCount = externalEvents.filter { calendar.isDate($0.startDate, inSameDayAs: tomorrow) }.count
        return TomorrowSummary(taskCount: taskCount, eventCount: localCount + externalCount)
    }
}
