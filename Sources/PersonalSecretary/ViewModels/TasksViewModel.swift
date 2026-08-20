import Foundation

enum TaskTab: String, CaseIterable, Identifiable {
    case today = "Today"
    case upcoming = "Upcoming"
    case all = "All"
    case completed = "Completed"

    var id: String { rawValue }
}

/// Pure filtering logic for the Tasks screen — kept out of the View so it's
/// directly unit-testable and reusable (e.g. by Search).
enum TasksViewModel {
    static func filter(
        tasks: [TaskItem],
        tab: TaskTab,
        priority: Priority?,
        category: TaskCategory?,
        search: String,
        referenceDate: Date = .now,
        calendar: Calendar = .current
    ) -> [TaskItem] {
        var result: [TaskItem]
        switch tab {
        case .today:
            result = tasks.filter { ($0.dueDate.map { calendar.isDate($0, inSameDayAs: referenceDate) }) ?? false }
        case .upcoming:
            result = tasks.filter { task in
                guard let due = task.dueDate, !task.isCompleted else { return false }
                return due > calendar.startOfDay(for: referenceDate) && !calendar.isDate(due, inSameDayAs: referenceDate)
            }
        case .all:
            result = tasks
        case .completed:
            result = tasks.filter(\.isCompleted)
        }

        if let priority {
            result = result.filter { $0.priority == priority }
        }
        if let category {
            result = result.filter { $0.category == category }
        }
        let trimmedSearch = search.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedSearch.isEmpty {
            result = result.filter { $0.title.localizedCaseInsensitiveContains(trimmedSearch) }
        }

        return result.sorted { lhs, rhs in
            if lhs.isCompleted != rhs.isCompleted { return !lhs.isCompleted }
            switch (lhs.dueDate, rhs.dueDate) {
            case let (l?, r?): return l < r
            case (nil, .some): return false
            case (.some, nil): return true
            default: return lhs.priority.sortOrder < rhs.priority.sortOrder
            }
        }
    }
}
