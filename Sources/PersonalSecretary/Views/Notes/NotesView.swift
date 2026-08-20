import SwiftData
import SwiftUI

struct NotesView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppState.self) private var appState
    @Query private var allNotes: [Note]

    @State private var selectedNoteID: UUID?
    @State private var editorTitle = ""
    @State private var editorContent = ""
    @State private var saveTask: Task<Void, Never>?

    private var repository: NoteRepository { NoteRepository(context: modelContext) }

    private var sortedNotes: [Note] {
        allNotes.sorted { lhs, rhs in
            if lhs.pinned != rhs.pinned { return lhs.pinned }
            return lhs.updatedAt > rhs.updatedAt
        }
    }

    private var selectedNote: Note? {
        sortedNotes.first { $0.id == selectedNoteID } ?? sortedNotes.first
    }

    var body: some View {
        HStack(spacing: 0) {
            noteList
                .frame(width: 280)
                .padding(.trailing, 20)
                .overlay(alignment: .trailing) { Rectangle().fill(DT.Color.sidebarBorder).frame(width: 1) }

            editor
                .padding(.leading, 28)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxHeight: .infinity)
        .onAppear { selectedNoteID = sortedNotes.first?.id; loadEditor() }
        .onChange(of: selectedNote?.id) { _, _ in loadEditor() }
        .onChange(of: appState.newNoteRequestCount) { _, _ in createNote() }
    }

    private var noteList: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Notes").font(.system(size: 20, weight: .semibold)).foregroundStyle(DT.Color.textPrimary)
                Spacer()
                Button("+ New", action: createNote)
                    .buttonStyle(.plain)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(DT.Color.accentSoftText)
            }
            if sortedNotes.isEmpty {
                Spacer()
            } else {
                ScrollView {
                    VStack(spacing: 2) {
                        ForEach(sortedNotes) { note in
                            noteRow(note)
                        }
                    }
                    .padding(.top, 16)
                }
            }
        }
    }

    private func noteRow(_ note: Note) -> some View {
        let isActive = note.id == selectedNote?.id
        return VStack(alignment: .leading, spacing: 3) {
            HStack {
                Text(note.title.isEmpty ? "Untitled Note" : note.title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(DT.Color.textPrimary)
                    .lineLimit(1)
                Spacer()
                if note.pinned {
                    Circle().fill(DT.Color.orangeDot).frame(width: 6, height: 6)
                }
            }
            Text(note.preview)
                .font(.system(size: 12))
                .foregroundStyle(DT.Color.textTertiary)
                .lineLimit(1)
            HStack {
                CategoryChip(category: note.category)
                Spacer()
                Text(note.updatedAt.relativeShortLabel)
                    .font(.system(size: 11))
                    .foregroundStyle(DT.Color.textPlaceholder)
            }
            .padding(.top, 3)
        }
        .padding(12)
        .background(isActive ? DT.Color.sidebarBackground : .clear)
        .clipShape(RoundedRectangle(cornerRadius: DT.Radius.mdl, style: .continuous))
        .contentShape(Rectangle())
        .onTapGesture { selectedNoteID = note.id }
    }

    @ViewBuilder
    private var editor: some View {
        if let note = selectedNote {
            VStack(alignment: .leading, spacing: 0) {
                TextField("Title", text: $editorTitle)
                    .textFieldStyle(.plain)
                    .font(.system(size: 22, weight: .semibold))
                    .onChange(of: editorTitle) { _, _ in scheduleSave(note) }

                HStack(spacing: 14) {
                    Image(systemName: "bold").font(.system(size: 12)).foregroundStyle(DT.Color.textSecondary)
                    Image(systemName: "italic").font(.system(size: 12)).foregroundStyle(DT.Color.textSecondary)
                    Image(systemName: "list.bullet").font(.system(size: 12)).foregroundStyle(DT.Color.textSecondary)
                    Spacer()
                    Button(note.pinned ? "Unpin" : "Pin") { togglePin(note) }
                        .buttonStyle(.plain)
                        .font(.system(size: 11))
                        .foregroundStyle(DT.Color.textSecondary)
                    Picker("", selection: Binding(get: { note.category }, set: { note.category = $0; repository.update() })) {
                        ForEach(TaskCategory.allCases) { Text($0.rawValue).tag($0) }
                    }
                    .labelsHidden()
                    .frame(width: 110)
                    Button("Delete") { delete(note) }
                        .buttonStyle(.plain)
                        .font(.system(size: 11))
                        .foregroundStyle(DT.Color.dangerText)
                    Text("Saved")
                        .font(.system(size: 11))
                        .foregroundStyle(DT.Color.textPlaceholder)
                }
                .padding(.vertical, 14)
                .overlay(alignment: .bottom) { Rectangle().fill(DT.Color.sidebarBorder).frame(height: 1) }

                TextEditor(text: $editorContent)
                    .scrollContentBackground(.hidden)
                    .font(.system(size: 14))
                    .lineSpacing(6)
                    .onChange(of: editorContent) { _, _ in scheduleSave(note) }
                    .frame(minHeight: 340)
            }
        } else {
            EmptyStateView(
                symbol: "pencil.and.scribble",
                iconBackground: DT.Color.goldBackground,
                iconForeground: DT.Color.goldDot,
                title: "No notes yet",
                subtitle: "Capture anything worth remembering.",
                actionTitle: "New Note",
                action: createNote
            )
            .padding(.top, 100)
        }
    }

    private func loadEditor() {
        guard let note = selectedNote else { editorTitle = ""; editorContent = ""; return }
        editorTitle = note.title
        editorContent = note.content
    }

    private func scheduleSave(_ note: Note) {
        saveTask?.cancel()
        let title = editorTitle
        let content = editorContent
        saveTask = Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(500))
            guard !Task.isCancelled else { return }
            note.title = title.isEmpty ? "Untitled Note" : title
            note.content = content
            note.updatedAt = .now
            repository.update()
        }
    }

    private func createNote() {
        let note = Note()
        repository.create(note)
        selectedNoteID = note.id
    }

    private func togglePin(_ note: Note) {
        note.pinned.toggle()
        repository.update()
    }

    private func delete(_ note: Note) {
        if note.id == selectedNoteID { selectedNoteID = nil }
        repository.delete(note)
    }
}
