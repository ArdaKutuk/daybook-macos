import Foundation
import SwiftData

@MainActor
struct FileShortcutRepository {
    let context: ModelContext

    func fetchAll() -> [FileShortcut] {
        (try? context.fetch(FetchDescriptor<FileShortcut>(sortBy: [SortDescriptor(\.sortOrder)]))) ?? []
    }

    func create(_ shortcut: FileShortcut) {
        context.insert(shortcut)
        save()
    }

    func delete(_ shortcut: FileShortcut) {
        context.delete(shortcut)
        save()
    }

    func update() { save() }

    @discardableResult
    private func save() -> Bool {
        do { try context.save(); return true }
        catch { print("FileShortcutRepository save error: \(error)"); return false }
    }
}
