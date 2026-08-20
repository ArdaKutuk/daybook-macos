import Foundation

/// Pure, timezone-safe streak math for Routines. Kept independent of
/// SwiftData so it's directly unit-testable and so the same logic can't
/// drift between the model and its tests.
enum StreakCalculator {

    /// - Parameters:
    ///   - completionDays: Set of start-of-day dates the routine was completed on.
    ///   - frequency / selectedWeekdays: determine which days "count" toward the streak.
    ///   - createdAt: earliest day to consider when scanning for the best streak.
    ///   - referenceDate: "today", injectable for deterministic tests.
    static func computeStreaks(
        completionDays: Set<Date>,
        frequency: RoutineFrequency,
        selectedWeekdays: [Weekday],
        createdAt: Date,
        referenceDate: Date = .now,
        calendar: Calendar = .current
    ) -> (current: Int, best: Int) {
        let normalizedCompletions = Set(completionDays.map { calendar.startOfDay(for: $0) })

        func isScheduled(_ date: Date) -> Bool {
            switch frequency {
            case .daily, .weekly:
                return true
            case .selectedDays:
                guard !selectedWeekdays.isEmpty else { return true }
                let weekday = calendar.component(.weekday, from: date)
                return selectedWeekdays.contains { $0.calendarWeekday == weekday }
            }
        }

        // MARK: Current streak — walk backward from today.
        var current = 0
        var cursor = calendar.startOfDay(for: referenceDate)
        let today = cursor

        // If today is scheduled but not yet completed, that shouldn't break an
        // in-progress streak — just start counting from yesterday instead.
        if isScheduled(cursor), !normalizedCompletions.contains(cursor) {
            cursor = calendar.date(byAdding: .day, value: -1, to: cursor) ?? cursor
        }

        var safety = 0
        while safety < 3650 {
            safety += 1
            if cursor < calendar.startOfDay(for: createdAt).adding(days: -1, calendar: calendar) { break }
            if isScheduled(cursor) {
                if normalizedCompletions.contains(cursor) {
                    current += 1
                    cursor = calendar.date(byAdding: .day, value: -1, to: cursor) ?? cursor
                } else {
                    break
                }
            } else {
                cursor = calendar.date(byAdding: .day, value: -1, to: cursor) ?? cursor
            }
        }

        // MARK: Best streak — scan forward across the routine's whole lifetime.
        var best = 0
        var running = 0
        var day = calendar.startOfDay(for: createdAt)
        let end = max(today, day)
        var forwardSafety = 0
        while day <= end, forwardSafety < 3650 {
            forwardSafety += 1
            if isScheduled(day) {
                if normalizedCompletions.contains(day) {
                    running += 1
                    best = max(best, running)
                } else {
                    running = 0
                }
            }
            day = calendar.date(byAdding: .day, value: 1, to: day) ?? end.adding(days: 1, calendar: calendar)
        }

        return (current, max(best, current))
    }

    @MainActor
    static func recompute(_ routine: Routine, referenceDate: Date = .now, calendar: Calendar = .current) {
        let completionDays = Set((routine.completions ?? []).map(\.date))
        let (current, best) = computeStreaks(
            completionDays: completionDays,
            frequency: routine.frequency,
            selectedWeekdays: routine.selectedWeekdays,
            createdAt: routine.createdAt,
            referenceDate: referenceDate,
            calendar: calendar
        )
        routine.currentStreak = current
        routine.bestStreak = best
    }
}
