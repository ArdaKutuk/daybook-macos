import Foundation

enum OverviewRange: Int, CaseIterable, Identifiable {
    case week = 7
    case month = 30
    var id: Int { rawValue }
    var label: String { self == .week ? "7 Days" : "30 Days" }
}

struct OverviewStats {
    var tasksCompleted: Int
    var completionRatePct: Int
    var focusTimeLabel: String
    var focusSessions: Int
    var routineCompletionPct: Int
    var mostProductiveDay: String
    var chartBars: [(label: String, count: Int)]
}

/// All Overview math lives here, pure and date-injectable, so it's directly
/// unit-testable without a SwiftData store.
enum OverviewViewModel {
    static func computeStats(
        tasks: [TaskItem],
        routines: [Routine],
        sessions: [FocusSession],
        range: OverviewRange,
        referenceDate: Date = .now,
        calendar: Calendar = .current
    ) -> OverviewStats {
        let today = calendar.startOfDay(for: referenceDate)
        let rangeStart = today.adding(days: -(range.rawValue - 1), calendar: calendar)
        let interval = DateInterval(start: rangeStart, end: today.adding(days: 1, calendar: calendar))

        let tasksInRange = tasks.filter { task in
            guard let due = task.dueDate else { return false }
            return interval.contains(due)
        }
        let completedInRange = tasksInRange.filter(\.isCompleted)
        let completionRate = tasksInRange.isEmpty ? 0 : Int((Double(completedInRange.count) / Double(tasksInRange.count) * 100).rounded())

        let sessionsInRange = sessions.filter { interval.contains($0.startDate) }
        let focusSeconds = Int(sessionsInRange.reduce(0) { $0 + $1.duration })

        var scheduledDayCount = 0
        var completedDayCount = 0
        var day = rangeStart
        while day < interval.end {
            for routine in routines where routine.isScheduled(on: day, calendar: calendar) {
                scheduledDayCount += 1
                if (routine.completions ?? []).contains(where: { $0.date.isSameDay(as: day, calendar: calendar) }) {
                    completedDayCount += 1
                }
            }
            day = calendar.date(byAdding: .day, value: 1, to: day) ?? interval.end
        }
        let routineCompletionPct = scheduledDayCount == 0 ? 0 : Int((Double(completedDayCount) / Double(scheduledDayCount) * 100).rounded())

        let weekdayFormatter = DateFormatter()
        weekdayFormatter.dateFormat = "EEEE"
        var completedByWeekday: [String: Int] = [:]
        for task in completedInRange {
            guard let completedAt = task.completedAt else { continue }
            let name = weekdayFormatter.string(from: completedAt)
            completedByWeekday[name, default: 0] += 1
        }
        let mostProductiveDay = completedByWeekday.max(by: { $0.value < $1.value })?.key ?? "—"

        var bars: [(label: String, count: Int)] = []
        var cursor = rangeStart
        let dayLabelFormatter = DateFormatter()
        dayLabelFormatter.dateFormat = range == .week ? "EEE" : "d"
        while cursor < interval.end {
            let count = completedInRange.filter { ($0.completedAt.map { calendar.isDate($0, inSameDayAs: cursor) }) ?? false }.count
            bars.append((dayLabelFormatter.string(from: cursor), count))
            cursor = calendar.date(byAdding: .day, value: 1, to: cursor) ?? interval.end
        }

        return OverviewStats(
            tasksCompleted: completedInRange.count,
            completionRatePct: completionRate,
            focusTimeLabel: DashboardViewModel.formattedDuration(seconds: focusSeconds),
            focusSessions: sessionsInRange.count,
            routineCompletionPct: routineCompletionPct,
            mostProductiveDay: mostProductiveDay,
            chartBars: bars
        )
    }
}
