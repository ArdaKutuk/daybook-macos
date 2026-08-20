import XCTest
@testable import PersonalSecretary

final class RoutineStreakTests: XCTestCase {
    private var calendar: Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "UTC")!
        return cal
    }

    private func day(_ offset: Int, from reference: Date, calendar: Calendar) -> Date {
        calendar.date(byAdding: .day, value: offset, to: calendar.startOfDay(for: reference))!
    }

    func testDailyStreakCountsConsecutiveCompletedDaysBackFromToday() {
        let cal = calendar
        let today = cal.startOfDay(for: .now)
        // Completed today, yesterday, and the day before — a 3-day streak.
        let completions: Set<Date> = [day(0, from: today, calendar: cal), day(-1, from: today, calendar: cal), day(-2, from: today, calendar: cal)]

        let result = StreakCalculator.computeStreaks(
            completionDays: completions,
            frequency: .daily,
            selectedWeekdays: [],
            createdAt: day(-10, from: today, calendar: cal),
            referenceDate: today,
            calendar: cal
        )

        XCTAssertEqual(result.current, 3)
        XCTAssertGreaterThanOrEqual(result.best, 3)
    }

    func testStreakDoesNotBreakWhenTodayIsNotYetCompleted() {
        let cal = calendar
        let today = cal.startOfDay(for: .now)
        // Yesterday and the day before are done; today hasn't happened yet.
        let completions: Set<Date> = [day(-1, from: today, calendar: cal), day(-2, from: today, calendar: cal)]

        let result = StreakCalculator.computeStreaks(
            completionDays: completions,
            frequency: .daily,
            selectedWeekdays: [],
            createdAt: day(-10, from: today, calendar: cal),
            referenceDate: today,
            calendar: cal
        )

        XCTAssertEqual(result.current, 2, "An unfinished 'today' shouldn't zero out an in-progress streak")
    }

    func testStreakBreaksOnAMissedScheduledDay() {
        let cal = calendar
        let today = cal.startOfDay(for: .now)
        // Completed today, but yesterday was missed — streak resets to 1.
        let completions: Set<Date> = [day(0, from: today, calendar: cal), day(-2, from: today, calendar: cal)]

        let result = StreakCalculator.computeStreaks(
            completionDays: completions,
            frequency: .daily,
            selectedWeekdays: [],
            createdAt: day(-10, from: today, calendar: cal),
            referenceDate: today,
            calendar: cal
        )

        XCTAssertEqual(result.current, 1)
    }

    func testSelectedDaysFrequencyIgnoresNonScheduledDays() {
        let cal = calendar
        // Anchor "today" to a known Wednesday so weekday math is deterministic.
        let wednesday = cal.date(from: DateComponents(year: 2026, month: 8, day: 19))!
        XCTAssertEqual(cal.component(.weekday, from: wednesday), 4) // Wednesday

        // Scheduled Mon/Wed/Fri only. Completed the last three scheduled days.
        let monday = day(-2, from: wednesday, calendar: cal)
        let priorFriday = day(-5, from: wednesday, calendar: cal)
        let completions: Set<Date> = [wednesday, monday, priorFriday]

        let result = StreakCalculator.computeStreaks(
            completionDays: completions,
            frequency: .selectedDays,
            selectedWeekdays: [.monday, .wednesday, .friday],
            createdAt: day(-30, from: wednesday, calendar: cal),
            referenceDate: wednesday,
            calendar: cal
        )

        XCTAssertEqual(result.current, 3, "Tuesday/Thursday/weekend gaps shouldn't count against the streak")
    }

    func testBestStreakSurvivesAfterCurrentStreakBreaks() {
        let cal = calendar
        let today = cal.startOfDay(for: .now)
        // A 4-day streak from -9 to -6, then a gap, then only today completed.
        var completions: Set<Date> = []
        for offset in [-9, -8, -7, -6] { completions.insert(day(offset, from: today, calendar: cal)) }
        completions.insert(day(0, from: today, calendar: cal))

        let result = StreakCalculator.computeStreaks(
            completionDays: completions,
            frequency: .daily,
            selectedWeekdays: [],
            createdAt: day(-20, from: today, calendar: cal),
            referenceDate: today,
            calendar: cal
        )

        XCTAssertEqual(result.current, 1)
        XCTAssertEqual(result.best, 4)
    }
}
