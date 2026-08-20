import XCTest
@testable import PersonalSecretary

final class RecurringTaskLogicTests: XCTestCase {
    private var utcCalendar: Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "UTC")!
        return cal
    }

    func testNoneRuleProducesNoOccurrence() {
        let task = TaskItem(title: "One-off", dueDate: .now, recurrenceRule: .none)
        XCTAssertNil(RecurrenceEngine.nextOccurrence(of: task))
    }

    func testDailyRuleAdvancesOneDay() {
        let cal = utcCalendar
        let due = cal.date(from: DateComponents(year: 2026, month: 8, day: 19))!
        let task = TaskItem(title: "Daily standup", dueDate: due, recurrenceRule: .daily)

        let next = RecurrenceEngine.nextOccurrence(of: task, calendar: cal)!

        XCTAssertEqual(cal.dateComponents([.year, .month, .day], from: next.dueDate!), DateComponents(year: 2026, month: 8, day: 20))
        XCTAssertEqual(next.title, task.title)
        XCTAssertEqual(next.status, .pending)
        XCTAssertNil(next.completedAt)
    }

    func testWeeklyRuleAdvancesSevenDays() {
        let cal = utcCalendar
        let due = cal.date(from: DateComponents(year: 2026, month: 8, day: 19))!
        let task = TaskItem(title: "Weekly review", dueDate: due, recurrenceRule: .weekly)

        let next = RecurrenceEngine.nextOccurrence(of: task, calendar: cal)!

        XCTAssertEqual(cal.dateComponents([.year, .month, .day], from: next.dueDate!), DateComponents(year: 2026, month: 8, day: 26))
    }

    func testNextOccurrencePreservesTimeOfDayAndCategory() {
        let cal = utcCalendar
        let due = cal.date(from: DateComponents(year: 2026, month: 8, day: 19))!
        let time = cal.date(from: DateComponents(year: 2000, month: 1, day: 1, hour: 9, minute: 15))!
        let task = TaskItem(title: "Sync", dueDate: due, dueTime: time, priority: .high, category: .work, recurrenceRule: .daily)

        let next = RecurrenceEngine.nextOccurrence(of: task, calendar: cal)!

        XCTAssertEqual(next.dueTime, time)
        XCTAssertEqual(next.priority, .high)
        XCTAssertEqual(next.category, .work)
    }

    func testNextOccurrenceFallsBackToNowWhenNoDueDate() {
        let task = TaskItem(title: "Undated recurring", recurrenceRule: .daily)
        XCTAssertNotNil(RecurrenceEngine.nextOccurrence(of: task))
    }
}
