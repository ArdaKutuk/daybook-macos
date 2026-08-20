import SwiftData
import SwiftUI

struct NewRoutineSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppState.self) private var appState
    @Environment(NotificationService.self) private var notificationService

    @State private var name = ""
    @State private var symbol = "W"
    @State private var paletteIndex = 0
    @State private var isWeekly = false
    @State private var selectedDays: Set<Weekday> = []
    @State private var time = Date.now
    @State private var reminderEnabled = false

    private let iconLetters = ["W", "R", "M", "J", "S"]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("New Routine").font(.system(size: 17, weight: .semibold)).padding(.bottom, 18)

            AppTextField(placeholder: "Name", text: $name).padding(.bottom, 12)

            Text("Icon").font(.system(size: 12)).foregroundStyle(DT.Color.textSecondary).padding(.bottom, 6)
            HStack(spacing: 8) {
                ForEach(Array(iconLetters.enumerated()), id: \.offset) { index, letter in
                    let palette = DT.routineIconPalette[index % DT.routineIconPalette.count]
                    Text(letter)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(palette.fg)
                        .frame(width: 36, height: 36)
                        .background(palette.bg)
                        .clipShape(RoundedRectangle(cornerRadius: DT.Radius.mdl, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: DT.Radius.mdl, style: .continuous)
                                .stroke(paletteIndex == index ? DT.Color.accent : .clear, lineWidth: 2)
                        )
                        .contentShape(Rectangle())
                        .onTapGesture { symbol = letter; paletteIndex = index }
                }
            }
            .padding(.bottom, 14)

            Text("Frequency").font(.system(size: 12)).foregroundStyle(DT.Color.textSecondary).padding(.bottom, 6)
            SegmentedPill(options: [false, true], label: { $0 ? "Weekly" : "Daily" }, selection: $isWeekly)
                .padding(.bottom, 14)

            Text("Days").font(.system(size: 12)).foregroundStyle(DT.Color.textSecondary).padding(.bottom, 6)
            HStack(spacing: 6) {
                ForEach(Weekday.orderedMondayFirst) { day in
                    let active = selectedDays.contains(day)
                    Text(day.shortLabel)
                        .font(.system(size: 11))
                        .foregroundStyle(active ? .white : DT.Color.textSecondary)
                        .frame(width: 34, height: 34)
                        .background(active ? DT.Color.accent : DT.Color.sidebarBackground)
                        .clipShape(RoundedRectangle(cornerRadius: DT.Radius.md, style: .continuous))
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if selectedDays.contains(day) { selectedDays.remove(day) } else { selectedDays.insert(day) }
                        }
                }
            }
            .padding(.bottom, 14)

            HStack(spacing: 8) {
                DatePicker("", selection: $time, displayedComponents: .hourAndMinute).labelsHidden()
                Text("Reminder").font(.system(size: 12)).foregroundStyle(DT.Color.textSecondary)
                ToggleSwitch(isOn: $reminderEnabled)
            }
            .padding(.bottom, 18)

            HStack {
                Spacer()
                AppButton(title: "Cancel", style: .text) { appState.showRoutineSheet = false }
                AppButton(title: "Create", style: .primary, action: create)
            }
        }
        .padding(28)
        .frame(width: 440)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: DT.Radius.modal, style: .continuous))
        .shadow(color: DT.Shadow.modal.color, radius: DT.Shadow.modal.radius, y: DT.Shadow.modal.y)
    }

    private func create() {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { appState.showRoutineSheet = false; return }
        let frequency: RoutineFrequency = isWeekly && !selectedDays.isEmpty ? .selectedDays : (isWeekly ? .weekly : .daily)
        let routine = Routine(
            name: trimmed,
            symbol: symbol,
            frequency: frequency,
            selectedWeekdays: Array(selectedDays),
            preferredTime: time,
            reminderEnabled: reminderEnabled,
            paletteIndex: paletteIndex
        )
        modelContext.insert(routine)
        try? modelContext.save()
        if reminderEnabled {
            notificationService.scheduleRoutineReminder(routineID: routine.id, name: routine.name, fireDate: time)
        }
        appState.showRoutineSheet = false
    }
}
