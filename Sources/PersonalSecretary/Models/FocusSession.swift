import Foundation
import SwiftData

@Model
final class FocusSession {
    var id: UUID = UUID()
    var startDate: Date = Date.now
    var endDate: Date = Date.now
    var duration: TimeInterval = 0
    var completed: Bool = false
    var relatedTask: TaskItem?
    var taskLabel: String = ""

    init(
        id: UUID = UUID(),
        startDate: Date,
        endDate: Date,
        duration: TimeInterval,
        completed: Bool,
        relatedTask: TaskItem? = nil,
        taskLabel: String = ""
    ) {
        self.id = id
        self.startDate = startDate
        self.endDate = endDate
        self.duration = duration
        self.completed = completed
        self.relatedTask = relatedTask
        self.taskLabel = taskLabel.isEmpty ? (relatedTask?.title ?? "Focus Session") : taskLabel
    }
}
