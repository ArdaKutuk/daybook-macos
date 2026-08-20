import SwiftData
import SwiftUI

struct DashboardView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @Environment(CalendarService.self) private var calendarService

    @Query private var allTasks: [TaskItem]
    @Query private var allRoutines: [Routine]
    @Query private var allSessions: [FocusSession]
    @Query private var localEvents: [LocalEvent]

    @AppStorage("dashboardQuickNoteText") private var quickNoteText = ""

    private let columns = [GridItem(.adaptive(minimum: 280), spacing: 20)]

    private var todaysTasks: [TaskItem] { DashboardViewModel.tasksDueToday(allTasks) }
    private var progress: (done: Int, total: Int, pct: Double) { DashboardViewModel.progress(tasks: todaysTasks) }
    private var routineProgress: (done: Int, total: Int) { DashboardViewModel.routineProgress(allRoutines) }
    private var focusSeconds: Int { DashboardViewModel.focusTotalSeconds(allSessions) }
    private var focusSessionsToday: Int {
        allSessions.filter { $0.startDate.isSameDay(as: .now) }.count
    }

    private var nextEvent: (title: String, time: String, date: Date)? {
        let now = Date.now
        let local = localEvents.filter { $0.startDate >= now }.map { (title: $0.title, time: $0.startDate.timeHHmm, date: $0.startDate) }
        let external = calendarService.externalEvents.filter { $0.startDate >= now }.map { (title: $0.title, time: $0.startDate.timeHHmm, date: $0.startDate) }
        return (local + external).min { $0.date < $1.date }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(Greeting.forCurrentTime())
                .font(DT.Font.dashboardGreeting)
                .foregroundStyle(DT.Color.textPrimary)
            Text(Date.now.weekdayName + ", " + Date.now.monthDayLabel)
                .font(.system(size: 14))
                .foregroundStyle(DT.Color.textSecondary)
                .padding(.top, 4)
            Text("Here's your day at a glance.")
                .font(.system(size: 13))
                .foregroundStyle(DT.Color.textTertiary)
                .padding(.top, 2)

            LazyVGrid(columns: columns, spacing: 20) {
                todaysTasksCard
                    .gridCellColumns(2)
                upcomingEventCard
                ProgressCard(
                    label: "Daily Progress",
                    valueText: "\(progress.done) of \(progress.total) tasks completed",
                    progress: progress.pct
                )
                focusSummaryCard
                routineProgressCard
                quickNoteCard
                tomorrowCard
            }
            .padding(.top, 28)
        }
        .onAppear {
            calendarService.loadEvents(from: .now.startOfDay, to: .now.adding(days: 2))
        }
    }

    private var todaysTasksCard: some View {
        CardContainer {
            VStack(alignment: .leading, spacing: 0) {
                Text("Today's Tasks")
                    .font(DT.Font.cardTitle)
                    .foregroundStyle(DT.Color.textPrimary)
                    .padding(.bottom, 14)
                if todaysTasks.isEmpty {
                    Text("Nothing due today. Enjoy the calm.")
                        .font(.system(size: 13))
                        .foregroundStyle(DT.Color.textTertiary)
                        .padding(.vertical, 8)
                } else {
                    VStack(spacing: 2) {
                        ForEach(todaysTasks.prefix(6)) { task in
                            TaskRow(task: task, style: .compact, onToggle: { toggle(task) })
                        }
                    }
                }
            }
        }
        .frame(minWidth: 320)
    }

    private var upcomingEventCard: some View {
        CardContainer {
            VStack(alignment: .leading, spacing: 0) {
                CardLabel(text: "Upcoming Event").padding(.bottom, 14)
                if let nextEvent {
                    Text(nextEvent.time)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(DT.Color.textPrimary)
                    Text(nextEvent.title)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(DT.Color.textPrimary)
                        .padding(.top, 6)
                    Text(startsInLabel(nextEvent.date))
                        .font(.system(size: 12))
                        .foregroundStyle(DT.Color.textTertiary)
                        .padding(.top, 4)
                } else {
                    Text("No upcoming events")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(DT.Color.textPrimary)
                    Text("Your calendar is clear.")
                        .font(.system(size: 12))
                        .foregroundStyle(DT.Color.textTertiary)
                        .padding(.top, 4)
                }
            }
        }
    }

    private var focusSummaryCard: some View {
        CardContainer {
            VStack(alignment: .leading, spacing: 0) {
                CardLabel(text: "Focus Summary").padding(.bottom, 14)
                Text(DashboardViewModel.formattedDuration(seconds: focusSeconds))
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(DT.Color.textPrimary)
                Text("\(focusSessionsToday) sessions")
                    .font(.system(size: 12))
                    .foregroundStyle(DT.Color.textTertiary)
                    .padding(.top, 4)
                Button("Start Focus") { appState.navigate(to: .focus) }
                    .buttonStyle(.plain)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(DT.Color.accentSoftText)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background(DT.Color.accentSoftBackground)
                    .clipShape(Capsule())
                    .padding(.top, 14)
            }
        }
    }

    private var routineProgressCard: some View {
        CardContainer {
            VStack(alignment: .leading, spacing: 0) {
                CardLabel(text: "Routine Progress").padding(.bottom, 14)
                Text("\(routineProgress.done) / \(routineProgress.total) routines complete")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(DT.Color.textPrimary)
                HStack(spacing: 6) {
                    ForEach(Array(DashboardViewModel.routinesScheduledToday(allRoutines).prefix(5))) { routine in
                        let done = (routine.completions ?? []).contains { $0.date.isSameDay(as: .now) }
                        let palette = DT.routineIconPalette[routine.paletteIndex % DT.routineIconPalette.count]
                        RoundedRectangle(cornerRadius: 7, style: .continuous)
                            .fill(done ? palette.bg : DT.Color.sidebarBackground)
                            .frame(width: 22, height: 22)
                            .overlay {
                                if done {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundStyle(palette.fg)
                                }
                            }
                    }
                }
                .padding(.top, 14)
            }
        }
    }

    private var quickNoteCard: some View {
        CardContainer {
            VStack(alignment: .leading, spacing: 0) {
                CardLabel(text: "Quick Note").padding(.bottom, 12)
                TextEditor(text: $quickNoteText)
                    .scrollContentBackground(.hidden)
                    .font(.system(size: 13))
                    .frame(height: 70)
                    .padding(10)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: DT.Radius.mdl, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: DT.Radius.mdl, style: .continuous).stroke(DT.Color.cardBorder, lineWidth: 1))
                Text("Autosaved")
                    .font(.system(size: 11))
                    .foregroundStyle(DT.Color.textPlaceholder)
                    .padding(.top, 6)
            }
        }
    }

    private var tomorrowCard: some View {
        let summary = DashboardViewModel.tomorrowSummary(tasks: allTasks, localEvents: localEvents, externalEvents: calendarService.externalEvents)
        return CardContainer {
            VStack(alignment: .leading, spacing: 0) {
                CardLabel(text: "Tomorrow").padding(.bottom, 14)
                Text("\(summary.taskCount) tasks · \(summary.eventCount) events")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(DT.Color.textPrimary)
                Text(summary.taskCount + summary.eventCount <= 2 ? "A lighter day ahead." : "A busy day ahead.")
                    .font(.system(size: 12))
                    .foregroundStyle(DT.Color.textTertiary)
                    .padding(.top, 6)
            }
        }
    }

    private func toggle(_ task: TaskItem) {
        TaskRepository(context: modelContext).setCompleted(task, !task.isCompleted)
    }

    private func startsInLabel(_ date: Date) -> String {
        let minutes = Int(date.timeIntervalSinceNow / 60)
        if minutes <= 0 { return "Happening now" }
        if minutes < 60 { return "Starts in \(minutes) min" }
        let hours = minutes / 60
        return "Starts in \(hours)h \(minutes % 60)m"
    }
}
