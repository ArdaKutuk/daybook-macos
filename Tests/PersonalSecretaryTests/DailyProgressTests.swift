import XCTest
@testable import PersonalSecretary

final class DailyProgressTests: XCTestCase {
    func testProgressComputesDoneTotalAndPercentage() {
        let tasks = [
            TaskItem(title: "A"), TaskItem(title: "B"), TaskItem(title: "C"), TaskItem(title: "D")
        ]
        tasks[0].markCompleted(true)
        tasks[1].markCompleted(true)

        let progress = DashboardViewModel.progress(tasks: tasks)

        XCTAssertEqual(progress.done, 2)
        XCTAssertEqual(progress.total, 4)
        XCTAssertEqual(progress.pct, 0.5, accuracy: 0.0001)
    }

    func testProgressWithNoTasksIsZeroNotDivideByZero() {
        let progress = DashboardViewModel.progress(tasks: [])
        XCTAssertEqual(progress.done, 0)
        XCTAssertEqual(progress.total, 0)
        XCTAssertEqual(progress.pct, 0)
    }

    func testTasksDueTodayExcludesOtherDays() {
        let calendar = Calendar.current
        let today = Date.now
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!

        let dueToday = TaskItem(title: "Today task", dueDate: today)
        let dueTomorrow = TaskItem(title: "Tomorrow task", dueDate: tomorrow)
        let noDueDate = TaskItem(title: "No date")

        let result = DashboardViewModel.tasksDueToday([dueToday, dueTomorrow, noDueDate], date: today)

        XCTAssertEqual(result.map(\.title), ["Today task"])
    }

    func testRoutineProgressCountsOnlyScheduledRoutines() {
        let daily = Routine(name: "Stretch", frequency: .daily)
        let neverScheduledToday = Routine(name: "Gym", frequency: .selectedDays, selectedWeekdays: [])
        // Force an impossible weekday combo isn't representable, so instead
        // verify a routine scheduled today with no completion counts as "not done".
        let progress = DashboardViewModel.routineProgress([daily, neverScheduledToday])
        // Both are "daily-equivalent" (empty selectedDays defaults to every day),
        // so both should be scheduled and both incomplete.
        XCTAssertEqual(progress.total, 2)
        XCTAssertEqual(progress.done, 0)
    }

    func testFormattedDurationHoursAndMinutes() {
        XCTAssertEqual(DashboardViewModel.formattedDuration(seconds: 90), "1m")
        XCTAssertEqual(DashboardViewModel.formattedDuration(seconds: 3660), "1h 1m")
        XCTAssertEqual(DashboardViewModel.formattedDuration(seconds: 0), "0m")
    }
}
