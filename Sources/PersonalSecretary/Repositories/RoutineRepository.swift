import Foundation
import SwiftData

@MainActor
struct RoutineRepository {
    let context: ModelContext

    func fetchAll() -> [Routine] {
        (try? context.fetch(FetchDescriptor<Routine>(sortBy: [SortDescriptor(\.createdAt)]))) ?? []
    }

    func create(_ routine: Routine) {
        context.insert(routine)
        save()
    }

    func delete(_ routine: Routine) {
        context.delete(routine)
        save()
    }

    func completions(for routine: Routine) -> [RoutineCompletion] {
        (routine.completions ?? []).sorted { $0.date < $1.date }
    }

    func toggleCompletion(for routine: Routine, on date: Date) {
        let day = Calendar.current.startOfDay(for: date)
        if let existing = (routine.completions ?? []).first(where: { $0.date.isSameDay(as: day) }) {
            context.delete(existing)
            routine.completions?.removeAll { $0.id == existing.id }
        } else {
            let completion = RoutineCompletion(date: day, routine: routine)
            context.insert(completion)
            routine.completions?.append(completion)
        }
        StreakCalculator.recompute(routine)
        save()
    }

    func update() { save() }

    @discardableResult
    private func save() -> Bool {
        do { try context.save(); return true }
        catch { print("RoutineRepository save error: \(error)"); return false }
    }
}
