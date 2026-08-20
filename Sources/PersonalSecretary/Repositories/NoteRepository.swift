import Foundation
import SwiftData

@MainActor
struct NoteRepository {
    let context: ModelContext

    func fetchAll() -> [Note] {
        (try? context.fetch(FetchDescriptor<Note>(sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]))) ?? []
    }

    func create(_ note: Note) {
        context.insert(note)
        save()
    }

    func delete(_ note: Note) {
        context.delete(note)
        save()
    }

    func update() { save() }

    @discardableResult
    private func save() -> Bool {
        do { try context.save(); return true }
        catch { print("NoteRepository save error: \(error)"); return false }
    }
}
