import SwiftData
import SwiftUI

struct FocusView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(FocusTimerManager.self) private var timer
    @Query(sort: \FocusSession.startDate, order: .reverse) private var allSessions: [FocusSession]
    @Query(sort: \TaskItem.title) private var tasks: [TaskItem]

    private var repository: FocusSessionRepository { FocusSessionRepository(context: modelContext) }
    private var todaySeconds: Int { DashboardViewModel.focusTotalSeconds(allSessions) }
    private var todaySessionCount: Int { allSessions.filter { $0.startDate.isSameDay(as: .now) }.count }

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Text("Focus Session")
                .font(.system(size: 13))
                .foregroundStyle(DT.Color.textTertiary)
                .padding(.top, 30)

            Text(timer.formattedRemaining)
                .font(DT.Font.timerDigits)
                .foregroundStyle(DT.Color.textPrimary)
                .padding(.top, 6)

            taskPicker
                .padding(.top, 4)

            TimerControl(
                isRunning: timer.isRunning,
                onStart: timer.start,
                onPause: timer.pause,
                onStop: timer.stop
            )
            .padding(.top, 28)

            SegmentedPill(options: FocusPreset.allCases, label: \.rawValue, selection: Binding(
                get: { timer.preset },
                set: { timer.applyPreset($0) }
            ))
            .padding(.top, 26)

            HStack(spacing: 40) {
                statBlock(value: DashboardViewModel.formattedDuration(seconds: todaySeconds), label: "Today's Focus")
                statBlock(value: "\(todaySessionCount)", label: "Sessions")
            }
            .padding(.top, 48)

            VStack(alignment: .leading, spacing: 0) {
                Text("Recent Sessions")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(DT.Color.textSecondary)
                    .padding(.bottom, 10)
                if allSessions.isEmpty {
                    Text("No sessions yet — start your first one above.")
                        .font(.system(size: 13))
                        .foregroundStyle(DT.Color.textTertiary)
                } else {
                    ForEach(Array(allSessions.prefix(5))) { session in
                        HStack {
                            Text(session.taskLabel).font(.system(size: 13)).foregroundStyle(DT.Color.textPrimary)
                            Spacer()
                            Text("\(Int(session.duration / 60)) min · \(session.startDate.relativeShortLabel)")
                                .font(.system(size: 12))
                                .foregroundStyle(DT.Color.textTertiary)
                        }
                        .padding(.vertical, 10)
                        if session.id != allSessions.prefix(5).last?.id {
                            Rectangle().fill(DT.Color.divider).frame(height: 1)
                        }
                    }
                }
            }
            .frame(maxWidth: 420)
            .padding(.top, 36)
        }
        .frame(maxWidth: .infinity)
        .onAppear {
            timer.onSessionFinished = { start, end, duration, completed, task, label in
                let session = FocusSession(startDate: start, endDate: end, duration: duration, completed: completed, relatedTask: task, taskLabel: label)
                repository.create(session)
            }
        }
    }

    private var taskPicker: some View {
        Menu {
            Button("No linked task") { timer.linkedTask = nil; timer.taskLabel = "Focus Session" }
            ForEach(tasks) { task in
                Button(task.title) { timer.linkedTask = task; timer.taskLabel = task.title }
            }
        } label: {
            Text(timer.linkedTask?.title ?? (timer.taskLabel.isEmpty ? "No linked task" : timer.taskLabel))
                .font(.system(size: 14))
                .foregroundStyle(DT.Color.textSecondary)
        }
        .menuStyle(.borderlessButton)
        .fixedSize()
    }

    private func statBlock(value: String, label: String) -> some View {
        VStack(spacing: 2) {
            Text(value).font(.system(size: 20, weight: .semibold)).foregroundStyle(DT.Color.textPrimary)
            Text(label).font(.system(size: 12)).foregroundStyle(DT.Color.textTertiary)
        }
    }
}
