import XCTest
@testable import PersonalSecretary

final class TaskCompletionTests: XCTestCase {
    func testMarkingCompleteSetsStatusAndTimestamp() {
        let task = TaskItem(title: "Write report")
        XCTAssertEqual(task.status, .pending)
        XCTAssertNil(task.completedAt)

        task.markCompleted(true)

        XCTAssertEqual(task.status, .completed)
        XCTAssertTrue(task.isCompleted)
        XCTAssertNotNil(task.completedAt)
    }

    func testUnmarkingCompleteClearsTimestamp() {
        let task = TaskItem(title: "Write report")
        task.markCompleted(true)
        XCTAssertNotNil(task.completedAt)

        task.markCompleted(false)

        XCTAssertEqual(task.status, .pending)
        XCTAssertFalse(task.isCompleted)
        XCTAssertNil(task.completedAt)
    }

    func testDueDateTimeCombinesDateAndTimeOfDay() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        let date = calendar.date(from: DateComponents(year: 2026, month: 8, day: 19))!
        let time = calendar.date(from: DateComponents(year: 2000, month: 1, day: 1, hour: 14, minute: 30))!

        let task = TaskItem(title: "Meeting", dueDate: date, dueTime: time)
        let combined = task.dueDateTime!
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: combined)

        XCTAssertEqual(components.year, 2026)
        XCTAssertEqual(components.month, 8)
        XCTAssertEqual(components.day, 19)
        XCTAssertEqual(components.hour, 14)
        XCTAssertEqual(components.minute, 30)
    }

    func testDueDateTimeFallsBackToStartOfDayWithoutTime() {
        let date = Date.now
        let task = TaskItem(title: "All-day", dueDate: date, dueTime: nil)
        XCTAssertEqual(task.dueDateTime, Calendar.current.startOfDay(for: date))
    }
}
