import AppKit
import SwiftData
import SwiftUI

/// The MenuBarExtra popover content, matching the prototype's floating
/// "Today at a glance" card. Also reused as the in-window preview behind the
/// top bar's ▾ button.
struct MenuBarPopoverView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.openWindow) private var openWindow
    @Environment(CalendarService.self) private var calendarService: CalendarService

    @Query(sort: \TaskItem.dueDate) private var tasks: [TaskItem]
    @Query(sort: \LocalEvent.startDate) private var localEvents: [LocalEvent]

    private var remainingToday: Int {
        tasks.filter { !$0.isCompleted && ($0.dueDate?.isSameDay(as: .now) ?? false) }.count
    }

    private var nextEvent: (title: String, time: String)? {
        let now = Date.now
        let upcomingLocal = localEvents.filter { $0.startDate >= now }.min(by: { $0.startDate < $1.startDate })
        let upcomingExternal = calendarService?.externalEvents.filter { $0.startDate >= now }.min(by: { $0.startDate < $1.startDate })
        switch (upcomingLocal, upcomingExternal) {
        case let (.some(local), .some(external)):
            return local.startDate <= external.startDate ? (local.title, local.startDate.timeHHmm) : (external.title, external.startDate.timeHHmm)
        case let (.some(local), nil): return (local.title, local.startDate.timeHHmm)
        case let (nil, .some(external)): return (external.title, external.startDate.timeHHmm)
        default: return nil
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Today")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(DT.Color.textPrimary)
            Text("\(remainingToday) task\(remainingToday == 1 ? "" : "s") remaining")
                .font(.system(size: 12))
                .foregroundStyle(DT.Color.textTertiary)
                .padding(.top, 2)

            if let nextEvent {
                Text("Next: \(nextEvent.time) \(nextEvent.title)")
                    .font(.system(size: 12))
                    .foregroundStyle(DT.Color.textSecondary)
                    .padding(.top, 10)
                    .padding(.top, 10)
                    .overlay(alignment: .top) { Rectangle().fill(DT.Color.divider).frame(height: 1) }
            }

            VStack(spacing: 6) {
                popoverAction("New Task") {
                    openApp()
                    appState.openNewTask()
                }
                popoverAction("Quick Note") {
                    openApp()
                    appState.navigate(to: .today)
                }
                popoverAction("Start Focus") {
                    openApp()
                    appState.navigate(to: .focus)
                }
                popoverAction("Open App", highlighted: true, action: openApp)
            }
            .padding(.top, 14)
        }
        .padding(18)
        .frame(width: 250)
        .background(DT.Color.cardBackground)
    }

    private func openApp() {
        NSApp.activate(ignoringOtherApps: true)
        openWindow(id: "main")
    }

    @ViewBuilder
    private func popoverAction(_ title: String, highlighted: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 12))
                .foregroundStyle(highlighted ? DT.Color.accentSoftText : DT.Color.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(highlighted ? DT.Color.accentSoftBackground : DT.Color.appBackground)
                .clipShape(RoundedRectangle(cornerRadius: DT.Radius.md, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}
