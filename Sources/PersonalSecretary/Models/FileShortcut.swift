import Foundation
import SwiftData

@Model
final class FileShortcut {
    var id: UUID = UUID()
    var displayName: String = ""
    var bookmarkData: Data = Data()
    var typeRaw: String = FileShortcutType.file.rawValue
    var category: String = "Other"
    var createdAt: Date = Date.now
    var sortOrder: Int = 0
    /// Set when the bookmark could not be resolved (file moved/deleted) so the
    /// UI can show a clear, human-readable state instead of failing silently.
    var isStale: Bool = false

    init(
        id: UUID = UUID(),
        displayName: String,
        bookmarkData: Data,
        type: FileShortcutType,
        category: String,
        sortOrder: Int = 0
    ) {
        self.id = id
        self.displayName = displayName
        self.bookmarkData = bookmarkData
        self.typeRaw = type.rawValue
        self.category = category
        self.createdAt = .now
        self.sortOrder = sortOrder
        self.isStale = false
    }

    var type: FileShortcutType {
        get { FileShortcutType(rawValue: typeRaw) ?? .file }
        set { typeRaw = newValue.rawValue }
    }
}
