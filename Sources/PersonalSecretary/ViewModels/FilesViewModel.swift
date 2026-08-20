import Foundation

enum FilesViewModel {
    /// Fixed section names, matching the prototype's four categories. Kept
    /// simple (no category-management UI) since that wasn't part of the design.
    static let sectionNames = ["Projects", "University", "Documents", "Personal"]

    static func grouped(_ shortcuts: [FileShortcut]) -> [(name: String, items: [FileShortcut])] {
        sectionNames.map { name in
            (name, shortcuts.filter { $0.category == name }.sorted { $0.sortOrder < $1.sortOrder })
        }
    }
}
