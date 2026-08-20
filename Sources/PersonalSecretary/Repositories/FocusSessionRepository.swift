import Foundation
import SwiftData

@MainActor
struct FocusSessionRepository {
    let context: ModelContext

    func fetchAll() -> [FocusSession] {
        (try? context.fetch(FetchDescriptor<FocusSession>(sortBy: [SortDescriptor(\.startDate, order: .reverse)]))) ?? []
    }

    func fetchRecent(limit: Int = 5) -> [FocusSession] {
        Array(fetchAll().prefix(limit))
    }

    func create(_ session: FocusSession) {
        context.insert(session)
        save()
    }

    @discardableResult
    private func save() -> Bool {
        do { try context.save(); return true }
        catch { print("FocusSessionRepository save error: \(error)"); return false }
    }
}
