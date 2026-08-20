import SwiftData
import SwiftUI

struct FilesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allShortcuts: [FileShortcut]
    @State private var errorMessage: String?

    private var repository: FileShortcutRepository { FileShortcutRepository(context: modelContext) }
    private let columns = [GridItem(.adaptive(minimum: 200), spacing: 12)]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Files").font(DT.Font.sectionTitle).foregroundStyle(DT.Color.textPrimary)

            if allShortcuts.isEmpty {
                EmptyStateView(
                    symbol: "folder",
                    iconBackground: DT.Color.lavenderBackground,
                    iconForeground: DT.Color.lavenderDot,
                    title: "No shortcuts yet",
                    subtitle: "Keep important files within reach.",
                    actionTitle: nil,
                    action: nil
                )
            } else {
                ForEach(FilesViewModel.grouped(allShortcuts), id: \.name) { section in
                    VStack(alignment: .leading, spacing: 0) {
                        HStack {
                            Text(section.name)
                                .font(DT.Font.cardLabel)
                                .foregroundStyle(DT.Color.textSecondary)
                            Spacer()
                            Button("+ Add Shortcut") { addShortcut(to: section.name) }
                                .buttonStyle(.plain)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(DT.Color.accentSoftText)
                        }
                        .padding(.bottom, 12)

                        if !section.items.isEmpty {
                            LazyVGrid(columns: columns, spacing: 12) {
                                ForEach(section.items) { shortcut in
                                    FileShortcutCard(
                                        shortcut: shortcut,
                                        onOpen: { open(shortcut) },
                                        onRemove: { repository.delete(shortcut) }
                                    )
                                }
                            }
                        }
                    }
                    .padding(.top, 26)
                }
            }
        }
        .alert("Couldn't Open File", isPresented: .constant(errorMessage != nil), presenting: errorMessage) { _ in
            Button("OK") { errorMessage = nil }
        } message: { message in
            Text(message)
        }
    }

    private func addShortcut(to section: String) {
        let urls = FileShortcutService.presentPicker()
        for (offset, url) in urls.enumerated() {
            guard let bookmark = try? FileShortcutService.makeBookmark(for: url) else { continue }
            let shortcut = FileShortcut(
                displayName: url.lastPathComponent,
                bookmarkData: bookmark,
                type: FileShortcutService.isDirectory(url) ? .folder : .file,
                category: section,
                sortOrder: (allShortcuts.filter { $0.category == section }.map(\.sortOrder).max() ?? 0) + offset + 1
            )
            repository.create(shortcut)
        }
    }

    private func open(_ shortcut: FileShortcut) {
        Task {
            let result = await FileShortcutService.open(bookmarkData: shortcut.bookmarkData)
            switch result {
            case .success(let refreshedBookmark):
                shortcut.isStale = false
                if let refreshedBookmark { shortcut.bookmarkData = refreshedBookmark }
                repository.update()
            case .failure(let error):
                shortcut.isStale = (error == .fileMissing)
                repository.update()
                errorMessage = error.errorDescription
            }
        }
    }
}

extension FileShortcutError: Equatable {
    static func == (lhs: FileShortcutError, rhs: FileShortcutError) -> Bool {
        lhs.errorDescription == rhs.errorDescription
    }
}
