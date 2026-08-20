import SwiftData
import SwiftUI

struct NewTaskSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppState.self) private var appState
    @Environment(NotificationService.self) private var notificationService

    @State private var title = ""
    @State private var description = ""
    @State private var date = Date.now
    @State private var includeTime = false
    @State private var time = Date.now
    @State private var priority: Priority = .medium
    @State private var category: TaskCategory = .work
    @State private var reminder: ReminderOffset = .none
    @State private var recurrence: RecurrenceRule = .none

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("New Task")
                .font(.system(size: 17, weight: .semibold))
                .padding(.bottom, 18)

            AppTextField(placeholder: "Title", text: $title)
                .padding(.bottom, 10)
            AppTextField(placeholder: "Description", text: $description, isMultiline: true)
                .frame(height: 56)
                .padding(.bottom, 10)

            HStack(spacing: 10) {
                DatePicker("", selection: $date, displayedComponents: .date)
                    .labelsHidden()
                Toggle("Time", isOn: $includeTime)
                if includeTime {
                    DatePicker("", selection: $time, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }
            }
            .padding(.bottom, 10)

            Text("Priority")
                .font(.system(size: 12))
                .foregroundStyle(DT.Color.textSecondary)
                .padding(.bottom, 6)
            SegmentedPill(options: Priority.allCases, label: \.rawValue, selection: $priority)
                .padding(.bottom, 12)

            HStack(spacing: 10) {
                Picker("Category", selection: $category) {
                    ForEach(TaskCategory.allCases) { Text($0.rawValue).tag($0) }
                }
                Picker("Reminder", selection: $reminder) {
                    ForEach(ReminderOffset.allCases) { Text($0.rawValue).tag($0) }
                }
                Picker("Repeat", selection: $recurrence) {
                    ForEach(RecurrenceRule.allCases) { Text($0.rawValue).tag($0) }
                }
            }
            .pickerStyle(.menu)
            .labelsHidden()
            .padding(.bottom, 16)

            HStack {
                Spacer()
                AppButton(title: "Cancel", style: .text) { appState.showNewTaskSheet = false }
                AppButton(title: "Create", style: .primary, action: create)
            }
        }
        .padding(28)
        .frame(width: 460)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: DT.Radius.modal, style: .continuous))
        .shadow(color: DT.Shadow.modal.color, radius: DT.Shadow.modal.radius, y: DT.Shadow.modal.y)
        .onAppear { title = appState.pendingTaskTitle }
    }

    private func create() {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            appState.showNewTaskSheet = false
            return
        }
        let task = TaskItem(
            title: trimmed,
            taskDescription: description,
            dueDate: date,
            dueTime: includeTime ? time : nil,
            priority: priority,
            category: category,
            reminderEnabled: reminder != .none,
            recurrenceRule: recurrence
        )
        modelContext.insert(task)
        try? modelContext.save()

        if reminder != .none, let minutesBefore = reminder.minutesBefore {
            let base = task.dueDateTime ?? date
            let fireDate = base.addingTimeInterval(TimeInterval(-minutesBefore * 60))
            notificationService.scheduleTaskReminder(taskID: task.id, title: task.title, fireDate: fireDate)
        }

        appState.pendingTaskTitle = ""
        appState.showNewTaskSheet = false
    }
}
