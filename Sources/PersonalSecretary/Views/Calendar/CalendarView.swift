import SwiftData
import SwiftUI

struct CalendarView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(CalendarService.self) private var calendarService
    @Environment(AppState.self) private var appState
    @Query private var localEvents: [LocalEvent]
    @Query private var tasks: [TaskItem]

    @State private var viewMode: CalendarViewMode = .month
    @State private var monthAnchor = Date.now
    @State private var showNewEvent = false

    @AppStorage(SettingsKeys.firstDayOfWeek) private var firstDayRaw = FirstWeekday.sunday.rawValue
    private var firstWeekday: FirstWeekday { FirstWeekday(rawValue: firstDayRaw) ?? .sunday }

    private var repository: EventRepository { EventRepository(context: modelContext) }

    private var selectedLocalEvent: LocalEvent? {
        guard let id = appState.selectedEventID else { return nil }
        return localEvents.first { $0.id == id }
    }
    private var selectedExternalEvent: ExternalEvent? {
        guard let id = appState.selectedExternalEventID else { return nil }
        return calendarService.externalEvents.first { $0.id == id }
    }

    var body: some View {
        HStack(alignment: .top, spacing: 24) {
            VStack(alignment: .leading, spacing: 0) {
                header
                accessBanner
                HStack(spacing: 10) {
                    Text(monthAnchor.monthYearLabel)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(DT.Color.textSecondary)
                    if viewMode == .month {
                        Button(action: { shiftMonth(-1) }) { Image(systemName: "chevron.left") }
                            .buttonStyle(.plain).font(.system(size: 11)).foregroundStyle(DT.Color.textTertiary)
                        Button(action: { shiftMonth(1) }) { Image(systemName: "chevron.right") }
                            .buttonStyle(.plain).font(.system(size: 11)).foregroundStyle(DT.Color.textTertiary)
                        Button("Today") { monthAnchor = .now }
                            .buttonStyle(.plain).font(.system(size: 11)).foregroundStyle(DT.Color.accentSoftText)
                    }
                }
                .padding(.top, 18)

                if viewMode == .month {
                    monthGrid
                } else {
                    hoursList
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if let selectedLocalEvent {
                EventDetailPanel(
                    title: selectedLocalEvent.title,
                    timeRange: "\(selectedLocalEvent.startDate.timeHHmm) – \(selectedLocalEvent.endDate.timeHHmm)",
                    location: selectedLocalEvent.location,
                    notes: selectedLocalEvent.eventDescription,
                    reminderLabel: selectedLocalEvent.reminder.rawValue,
                    onClose: { appState.selectedEventID = nil }
                )
            } else if let selectedExternalEvent {
                EventDetailPanel(
                    title: selectedExternalEvent.title,
                    timeRange: "\(selectedExternalEvent.startDate.timeHHmm) – \(selectedExternalEvent.endDate.timeHHmm)",
                    location: selectedExternalEvent.location ?? "",
                    notes: selectedExternalEvent.notes ?? "",
                    reminderLabel: "—",
                    onClose: { appState.selectedExternalEventID = nil }
                )
            }
        }
        .onAppear { refreshEvents() }
        .onChange(of: monthAnchor) { _, _ in refreshEvents() }
        .overlay {
            if showNewEvent {
                ModalOverlay(onTapBackground: { showNewEvent = false }) {
                    NewEventSheet(defaultDate: monthAnchor, onDismiss: { showNewEvent = false })
                }
            }
        }
    }

    private var header: some View {
        HStack {
            Text("Calendar").font(DT.Font.sectionTitle).foregroundStyle(DT.Color.textPrimary)
            Spacer()
            QuickActionButton(systemImage: "plus", action: { showNewEvent = true }).help("New Event")
            SegmentedPill(options: CalendarViewMode.allCases, label: \.rawValue, selection: $viewMode)
        }
    }

    @ViewBuilder
    private var accessBanner: some View {
        if calendarService.accessState == .notDetermined {
            Button {
                Task { await calendarService.requestAccess(); refreshEvents() }
            } label: {
                Text("Connect Apple Calendar to see your events here →")
                    .font(.system(size: 12))
                    .foregroundStyle(DT.Color.accentSoftText)
            }
            .buttonStyle(.plain)
            .padding(.top, 6)
        } else if calendarService.accessState == .denied {
            Text("Calendar access denied — showing Daybook events only.")
                .font(.system(size: 12))
                .foregroundStyle(DT.Color.textPlaceholder)
                .padding(.top, 6)
        }
    }

    private var monthGrid: some View {
        let cells = CalendarViewModel.monthCells(monthAnchor: monthAnchor, firstWeekday: firstWeekday)
        let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 7)
        return VStack(spacing: 6) {
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(CalendarViewModel.weekdayLabels(firstWeekday: firstWeekday), id: \.self) { label in
                    Text(label).font(.system(size: 11, weight: .medium)).foregroundStyle(DT.Color.textTertiary)
                        .frame(maxWidth: .infinity)
                }
            }
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(Array(cells.enumerated()), id: \.offset) { _, date in
                    dayCell(date)
                }
            }
        }
        .padding(.top, 14)
    }

    private func dayCell(_ date: Date?) -> some View {
        let isToday = date.map { $0.isSameDay(as: .now) } ?? false
        let chips = date.map { CalendarViewModel.chips(for: $0, localEvents: localEvents, externalEvents: calendarService.externalEvents, tasks: tasks) } ?? []
        return VStack(alignment: .leading, spacing: 4) {
            if let date {
                Text("\(Calendar.current.component(.day, from: date))")
                    .font(.system(size: 12, weight: isToday ? .bold : .medium))
                    .foregroundStyle(isToday ? DT.Color.accentSoftText : DT.Color.textSecondary)
                ForEach(chips.prefix(3)) { chip in
                    EventChip(title: chip.label, background: chip.background, foreground: chip.foreground) {
                        select(chip)
                    }
                }
            }
        }
        .padding(8)
        .frame(minHeight: 78, maxWidth: .infinity, alignment: .topLeading)
        .background(isToday ? DT.Color.accentSoftBackground : Color.white)
        .clipShape(RoundedRectangle(cornerRadius: DT.Radius.mdl, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: DT.Radius.mdl, style: .continuous)
                .stroke(isToday ? DT.Color.accentDot.opacity(0.5) : DT.Color.cardBorder, lineWidth: 1)
        )
        .opacity(date == nil ? 0 : 1)
    }

    private var hoursList: some View {
        let day = Date.now
        return CardContainer {
            VStack(spacing: 0) {
                ForEach(CalendarViewModel.dayHours(), id: \.self) { hour in
                    HStack(spacing: 16) {
                        Text(CalendarViewModel.hourLabel(hour))
                            .font(.system(size: 12))
                            .foregroundStyle(DT.Color.textTertiary)
                            .frame(width: 52, alignment: .leading)

                        let chips = CalendarViewModel.chips(for: day, localEvents: localEvents, externalEvents: calendarService.externalEvents, tasks: [])
                            .filter { chip in
                                if case .localEvent = chip.kind, let event = localEvents.first(where: { "local-\($0.id)" == chip.id }) {
                                    return Calendar.current.component(.hour, from: event.startDate) == hour
                                }
                                if case .externalEvent = chip.kind, let event = calendarService.externalEvents.first(where: { "ext-\($0.id)" == chip.id }) {
                                    return Calendar.current.component(.hour, from: event.startDate) == hour
                                }
                                return false
                            }
                        if let chip = chips.first {
                            Text(chip.label)
                                .font(.system(size: 13))
                                .foregroundStyle(chip.foreground)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(chip.background)
                                .clipShape(RoundedRectangle(cornerRadius: DT.Radius.md, style: .continuous))
                                .contentShape(Rectangle())
                                .onTapGesture { select(chip) }
                        }
                        Spacer()
                    }
                    .padding(.vertical, 12)
                    if hour != CalendarViewModel.dayHours().last {
                        Rectangle().fill(DT.Color.divider).frame(height: 1)
                    }
                }
            }
        }
        .padding(.top, 16)
    }

    private func select(_ chip: CalendarChip) {
        switch chip.kind {
        case .localEvent:
            appState.selectedExternalEventID = nil
            appState.selectedEventID = UUID(uuidString: String(chip.id.dropFirst("local-".count)))
        case .externalEvent:
            appState.selectedEventID = nil
            appState.selectedExternalEventID = String(chip.id.dropFirst("ext-".count))
        case .task:
            appState.navigate(to: .tasks)
        }
    }

    private func shiftMonth(_ delta: Int) {
        monthAnchor = Calendar.current.date(byAdding: .month, value: delta, to: monthAnchor) ?? monthAnchor
    }

    private func refreshEvents() {
        guard let interval = Calendar.current.dateInterval(of: .month, for: monthAnchor) else { return }
        calendarService.loadEvents(from: interval.start, to: interval.end)
    }
}
