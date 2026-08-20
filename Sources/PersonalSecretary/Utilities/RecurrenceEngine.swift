import Foundation

/// Pure recurrence math for `RecurrenceRule`, independent of SwiftData so
/// it's directly unit-testable.
enum RecurrenceEngine {
    static func nextDueDate(after date: Date, rule: RecurrenceRule, calendar: Calendar = .current) -> Date? {
        switch rule {
        case .none: return nil
        case .daily: return calendar.date(byAdding: .day, value: 1, to: date)
        case .weekly: return calendar.date(byAdding: .day, value: 7, to: date)
        }
    }

    /// Builds the next occurrence of a completed recurring task, or `nil` if
    /// the task doesn't recur. The clone starts fresh (pending, no
    /// completedAt) with its due date advanced per `rule`.
    static func nextOccurrence(of task: TaskItem, calendar: Calendar = .current) -> TaskItem? {
        guard task.recurrenceRule != .none else { return nil }
        let anchor = task.dueDate ?? .now
        guard let nextDate = nextDueDate(after: anchor, rule: task.recurrenceRule, calendar: calendar) else { return nil }
        return TaskItem(
            title: task.title,
            taskDescription: task.taskDescription,
            dueDate: nextDate,
            dueTime: task.dueTime,
            priority: task.priority,
            category: task.category,
            reminderEnabled: task.reminderEnabled,
            recurrenceRule: task.recurrenceRule
        )
    }
}
