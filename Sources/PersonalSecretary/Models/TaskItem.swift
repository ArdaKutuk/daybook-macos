import Foundation
import SwiftData

/// Represents a user task. Named `TaskItem` rather than `Task` to avoid
/// colliding with Swift's built-in concurrency `Task` type, which is used
/// throughout the app (e.g. `Task { await ... }`).
@Model
final class TaskItem {
    var id: UUID = UUID()
    var title: String = ""
    var taskDescription: String = ""
    var dueDate: Date?
    var dueTime: Date?
    var priorityRaw: String = Priority.medium.rawValue
    var categoryRaw: String = TaskCategory.work.rawValue
    var statusRaw: String = TaskStatus.pending.rawValue
    var createdAt: Date = Date.now
    var updatedAt: Date = Date.now
    var completedAt: Date?
    var reminderEnabled: Bool = false
    var reminderDate: Date?
    var recurrenceRuleRaw: String = RecurrenceRule.none.rawValue

    @Relationship(deleteRule: .nullify, inverse: \FocusSession.relatedTask)
    var focusSessions: [FocusSession]? = []

    init(
        id: UUID = UUID(),
        title: String,
        taskDescription: String = "",
        dueDate: Date? = nil,
        dueTime: Date? = nil,
        priority: Priority = .medium,
        category: TaskCategory = .work,
        status: TaskStatus = .pending,
        reminderEnabled: Bool = false,
        reminderDate: Date? = nil,
        recurrenceRule: RecurrenceRule = .none
    ) {
        self.id = id
        self.title = title
        self.taskDescription = taskDescription
        self.dueDate = dueDate
        self.dueTime = dueTime
        self.priorityRaw = priority.rawValue
        self.categoryRaw = category.rawValue
        self.statusRaw = status.rawValue
        self.createdAt = .now
        self.updatedAt = .now
        self.reminderEnabled = reminderEnabled
        self.reminderDate = reminderDate
        self.recurrenceRuleRaw = recurrenceRule.rawValue
    }

    var priority: Priority {
        get { Priority(rawValue: priorityRaw) ?? .medium }
        set { priorityRaw = newValue.rawValue }
    }

    var category: TaskCategory {
        get { TaskCategory(rawValue: categoryRaw) ?? .work }
        set { categoryRaw = newValue.rawValue }
    }

    var status: TaskStatus {
        get { TaskStatus(rawValue: statusRaw) ?? .pending }
        set { statusRaw = newValue.rawValue }
    }

    var recurrenceRule: RecurrenceRule {
        get { RecurrenceRule(rawValue: recurrenceRuleRaw) ?? .none }
        set { recurrenceRuleRaw = newValue.rawValue }
    }

    var isCompleted: Bool { status == .completed }

    /// Combines `dueDate` (calendar day) with `dueTime` (time-of-day) into a
    /// single instant, falling back gracefully when either half is missing.
    var dueDateTime: Date? {
        guard let dueDate else { return nil }
        guard let dueTime else { return Calendar.current.startOfDay(for: dueDate) }
        let calendar = Calendar.current
        let timeComponents = calendar.dateComponents([.hour, .minute], from: dueTime)
        return calendar.date(
            bySettingHour: timeComponents.hour ?? 0,
            minute: timeComponents.minute ?? 0,
            second: 0,
            of: dueDate
        )
    }

    func markCompleted(_ completed: Bool) {
        status = completed ? .completed : .pending
        completedAt = completed ? .now : nil
        updatedAt = .now
    }
}
