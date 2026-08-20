import Foundation
import SwiftData

@Model
final class Note {
    var id: UUID = UUID()
    var title: String = ""
    var content: String = ""
    var categoryRaw: String = TaskCategory.personal.rawValue
    var pinned: Bool = false
    var createdAt: Date = Date.now
    var updatedAt: Date = Date.now

    init(
        id: UUID = UUID(),
        title: String = "Untitled Note",
        content: String = "",
        category: TaskCategory = .personal,
        pinned: Bool = false
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.categoryRaw = category.rawValue
        self.pinned = pinned
        self.createdAt = .now
        self.updatedAt = .now
    }

    var category: TaskCategory {
        get { TaskCategory(rawValue: categoryRaw) ?? .personal }
        set { categoryRaw = newValue.rawValue }
    }

    var preview: String {
        content.isEmpty ? "No content yet" : content
    }
}
