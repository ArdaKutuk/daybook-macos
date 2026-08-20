import Foundation
import SwiftData

@Model
final class Routine {
    var id: UUID = UUID()
    var name: String = ""
    var routineDescription: String = ""
    var symbol: String = "W"
    var frequencyRaw: String = RoutineFrequency.daily.rawValue
    var selectedWeekdaysRaw: [Int] = []
    var preferredTime: Date?
    var reminderEnabled: Bool = false
    var currentStreak: Int = 0
    var bestStreak: Int = 0
    var createdAt: Date = Date.now
    var paletteIndex: Int = 0

    @Relationship(deleteRule: .cascade, inverse: \RoutineCompletion.routine)
    var completions: [RoutineCompletion]? = []

    init(
        id: UUID = UUID(),
        name: String,
        routineDescription: String = "",
        symbol: String = "W",
        frequency: RoutineFrequency = .daily,
        selectedWeekdays: [Weekday] = [],
        preferredTime: Date? = nil,
        reminderEnabled: Bool = false,
        paletteIndex: Int = 0
    ) {
        self.id = id
        self.name = name
        self.routineDescription = routineDescription
        self.symbol = symbol
        self.frequencyRaw = frequency.rawValue
        self.selectedWeekdaysRaw = selectedWeekdays.map(\.rawValue)
        self.preferredTime = preferredTime
        self.reminderEnabled = reminderEnabled
        self.currentStreak = 0
        self.bestStreak = 0
        self.createdAt = .now
        self.paletteIndex = paletteIndex
    }

    var frequency: RoutineFrequency {
        get { RoutineFrequency(rawValue: frequencyRaw) ?? .daily }
        set { frequencyRaw = newValue.rawValue }
    }

    var selectedWeekdays: [Weekday] {
        get { selectedWeekdaysRaw.compactMap(Weekday.init(rawValue:)) }
        set { selectedWeekdaysRaw = newValue.map(\.rawValue) }
    }

    /// Whether this routine is scheduled for the given date, per its frequency.
    func isScheduled(on date: Date, calendar: Calendar = .current) -> Bool {
        switch frequency {
        case .daily:
            return true
        case .weekly:
            return true
        case .selectedDays:
            guard !selectedWeekdays.isEmpty else { return true }
            let weekday = calendar.component(.weekday, from: date)
            return selectedWeekdays.contains { $0.calendarWeekday == weekday }
        }
    }

    var scheduleLabel: String {
        switch frequency {
        case .daily: return "Daily"
        case .weekly: return "Weekly"
        case .selectedDays:
            guard !selectedWeekdays.isEmpty else { return "Weekly" }
            let ordered = Weekday.orderedMondayFirst.filter { selectedWeekdays.contains($0) }
            return ordered.map(\.shortLabel).joined(separator: " • ")
        }
    }
}
