import Foundation
import SwiftData

@MainActor
struct EventRepository {
    let context: ModelContext

    func fetchAll() -> [LocalEvent] {
        (try? context.fetch(FetchDescriptor<LocalEvent>(sortBy: [SortDescriptor(\.startDate)]))) ?? []
    }

    func create(_ event: LocalEvent) {
        context.insert(event)
        save()
    }

    func delete(_ event: LocalEvent) {
        context.delete(event)
        save()
    }

    func update() { save() }

    @discardableResult
    private func save() -> Bool {
        do { try context.save(); return true }
        catch { print("EventRepository save error: \(error)"); return false }
    }
}
