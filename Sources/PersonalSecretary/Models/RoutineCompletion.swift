import Foundation
import SwiftData

@Model
final class RoutineCompletion {
    var id: UUID = UUID()
    /// Calendar day (midnight, local time) this completion is for. Normalizing
    /// to start-of-day keeps streak math immune to time-of-day / timezone drift.
    var date: Date = Calendar.current.startOfDay(for: .now)
    var completedAt: Date = Date.now
    var routine: Routine?

    init(id: UUID = UUID(), date: Date, routine: Routine?) {
        self.id = id
        self.date = Calendar.current.startOfDay(for: date)
        self.completedAt = .now
        self.routine = routine
    }
}
