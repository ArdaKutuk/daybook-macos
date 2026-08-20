import SwiftData
import SwiftUI

struct TasksView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(NotificationService.self) private var notificationService
    @Environment(AppState.self) private var appState
    @Query(sort: \TaskItem.createdAt, order: .reverse) private var allTasks: [TaskItem]

    @State private var tab: TaskTab = .today
    @State private var search = ""
    @State private var priorityFilter: Priority?
    @State private var categoryFilter: TaskCategory?

    private var repository: TaskRepository { TaskRepository(context: modelContext) }

    private var filtered: [TaskItem] {
        TasksViewModel.filter(tasks: allTasks, tab: tab, priority: priorityFilter, category: categoryFilter, search: search)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionHeader(title: "Tasks") {
                AppButton(title: "New Task", style: .primary) { appState.openNewTask() }
            }

            SegmentedPill(options: TaskTab.allCases, label: \.rawValue, selection: $tab)
                .padding(.top, 22)

            HStack(spacing: 10) {
                AppTextField(placeholder: "Search tasks...", text: $search)
                    .frame(maxWidth: 260)

                Picker("Priority", selection: $priorityFilter) {
                    Text("All Priorities").tag(Priority?.none)
                    ForEach(Priority.allCases) { p in Text(p.rawValue).tag(Priority?.some(p)) }
                }
                .pickerStyle(.menu)
                .frame(width: 150)

                Picker("Category", selection: $categoryFilter) {
                    Text("All Categories").tag(TaskCategory?.none)
                    ForEach(TaskCategory.allCases) { c in Text(c.rawValue).tag(TaskCategory?.some(c)) }
                }
                .pickerStyle(.menu)
                .frame(width: 160)

                Spacer()
            }
            .padding(.top, 16)

            if filtered.isEmpty {
                EmptyStateView(
                    symbol: "checkmark.circle",
                    iconBackground: DT.Color.accentSoftBackground,
                    iconForeground: DT.Color.accentDot,
                    title: "No tasks yet",
                    subtitle: "Your day is clear.",
                    actionTitle: "New Task",
                    action: { appState.openNewTask() }
                )
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(filtered.enumerated()), id: \.element.id) { index, task in
                        TaskRow(task: task, style: .full, onToggle: { toggle(task) }, onDelete: { delete(task) })
                        if index < filtered.count - 1 {
                            Rectangle().fill(DT.Color.divider).frame(height: 1)
                        }
                    }
                }
                .background(DT.Color.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: DT.Radius.card, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: DT.Radius.card, style: .continuous).stroke(DT.Color.cardBorder, lineWidth: 1))
                .padding(.top, 18)
            }
        }
    }

    private func toggle(_ task: TaskItem) {
        let completing = !task.isCompleted
        repository.setCompleted(task, completing)
        if completing {
            notificationService.cancelTaskReminder(taskID: task.id)
        }
    }

    private func delete(_ task: TaskItem) {
        notificationService.cancelTaskReminder(taskID: task.id)
        repository.delete(task)
    }
}
