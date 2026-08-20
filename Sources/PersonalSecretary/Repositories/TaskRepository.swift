import Foundation
import SwiftData

/// Thin data-access layer over SwiftData for `TaskItem`. Keeps ViewModels
/// free of `FetchDescriptor`/predicate plumbing and gives us one place to
/// handle save errors instead of scattering `try?` everywhere.
@MainActor
struct TaskRepository {
    let context: ModelContext

    func fetchAll() -> [TaskItem] {
        (try? context.fetch(FetchDescriptor<TaskItem>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)]))) ?? []
    }

    func create(_ task: TaskItem) {
        context.insert(task)
        save()
    }

    func delete(_ task: TaskItem) {
        context.delete(task)
        save()
    }

    func update() {
        save()
    }

    /// Marks a task complete/incomplete. When completing a recurring task,
    /// also inserts its next occurrence — keeping recurrence logic in one
    /// place rather than scattered across every screen that can toggle a task.
    func setCompleted(_ task: TaskItem, _ completed: Bool) {
        let wasCompleted = task.isCompleted
        task.markCompleted(completed)
        if completed, !wasCompleted, let next = RecurrenceEngine.nextOccurrence(of: task) {
            context.insert(next)
        }
        save()
    }

    @discardableResult
    private func save() -> Bool {
        do {
            try context.save()
            return true
        } catch {
            print("TaskRepository save error: \(error)")
            return false
        }
    }
}
