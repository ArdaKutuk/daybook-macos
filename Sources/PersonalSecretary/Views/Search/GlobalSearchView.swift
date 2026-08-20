import AppKit
import SwiftData
import SwiftUI

struct SearchResult: Identifiable {
    enum Kind: String { case task = "Task", note = "Note", event = "Event", routine = "Routine" }
    let id: String
    let title: String
    let kind: Kind
    let dot: Color
    let action: () -> Void
}

struct GlobalSearchView: View {
    @Environment(AppState.self) private var appState
    @Environment(CalendarService.self) private var calendarService
    @Query private var tasks: [TaskItem]
    @Query private var notes: [Note]
    @Query private var localEvents: [LocalEvent]
    @Query private var routines: [Routine]

    var onDismiss: () -> Void

    @State private var query = ""
    @State private var selectedIndex = 0
    @FocusState private var isFocused: Bool

    private var results: [SearchResult] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }

        var results: [SearchResult] = []
        results += tasks.filter { $0.title.localizedCaseInsensitiveContains(trimmed) }.map { task in
            SearchResult(id: "t\(task.id)", title: task.title, kind: .task, dot: DT.Color.accentDot) {
                appState.navigate(to: .tasks); onDismiss()
            }
        }
        results += notes.filter { $0.title.localizedCaseInsensitiveContains(trimmed) }.map { note in
            SearchResult(id: "n\(note.id)", title: note.title, kind: .note, dot: DT.Color.goldDot) {
                appState.selectedNoteID = note.id; appState.navigate(to: .notes); onDismiss()
            }
        }
        results += localEvents.filter { $0.title.localizedCaseInsensitiveContains(trimmed) }.map { event in
            SearchResult(id: "e\(event.id)", title: event.title, kind: .event, dot: DT.Color.lavenderDot) {
                appState.selectedEventID = event.id; appState.navigate(to: .calendar); onDismiss()
            }
        }
        results += calendarService.externalEvents.filter { $0.title.localizedCaseInsensitiveContains(trimmed) }.map { event in
            SearchResult(id: "x\(event.id)", title: event.title, kind: .event, dot: DT.Color.lavenderDot) {
                appState.selectedExternalEventID = event.id; appState.navigate(to: .calendar); onDismiss()
            }
        }
        results += routines.filter { $0.name.localizedCaseInsensitiveContains(trimmed) }.map { routine in
            SearchResult(id: "r\(routine.id)", title: routine.name, kind: .routine, dot: DT.Color.mintDot) {
                appState.navigate(to: .routines); onDismiss()
            }
        }
        return results
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            TextField("Search your day...", text: $query)
                .textFieldStyle(.plain)
                .font(.system(size: 16))
                .padding(.horizontal, 20)
                .padding(.vertical, 18)
                .focused($isFocused)
                .onChange(of: query) { _, _ in selectedIndex = 0 }
                .onSubmit { activateSelected() }
                .overlay(alignment: .bottom) { Rectangle().fill(DT.Color.cardBorder).frame(height: 1) }

            ScrollView {
                VStack(spacing: 2) {
                    if results.isEmpty, !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        Text("No results")
                            .font(.system(size: 13))
                            .foregroundStyle(DT.Color.textTertiary)
                            .padding(30)
                    } else {
                        ForEach(Array(results.enumerated()), id: \.element.id) { index, result in
                            resultRow(result, isSelected: index == selectedIndex)
                                .onTapGesture { result.action() }
                        }
                    }
                }
                .padding(8)
            }
            .frame(maxHeight: 400)
        }
        .frame(width: 560)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: DT.Radius.modalSmall, style: .continuous))
        .shadow(color: DT.Shadow.modal.color, radius: DT.Shadow.modal.radius, y: DT.Shadow.modal.y)
        .onAppear { isFocused = true }
        .onExitCommand(perform: onDismiss)
        .background(KeyCaptureView(onUp: moveUp, onDown: moveDown, onEnter: activateSelected))
    }

    private func resultRow(_ result: SearchResult, isSelected: Bool) -> some View {
        HStack(spacing: 12) {
            Circle().fill(result.dot).frame(width: 8, height: 8)
            Text(result.title).font(.system(size: 13)).foregroundStyle(DT.Color.textPrimary)
            Spacer()
            Text(result.kind.rawValue).font(.system(size: 11)).foregroundStyle(DT.Color.textTertiary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .background(isSelected ? DT.Color.appBackground : .clear)
        .clipShape(RoundedRectangle(cornerRadius: DT.Radius.mdl, style: .continuous))
        .contentShape(Rectangle())
    }

    private func moveUp() { selectedIndex = max(0, selectedIndex - 1) }
    private func moveDown() { selectedIndex = min(max(0, results.count - 1), selectedIndex + 1) }
    private func activateSelected() {
        guard results.indices.contains(selectedIndex) else { return }
        results[selectedIndex].action()
    }
}

/// Bridges arrow-key / return handling that SwiftUI doesn't expose directly
/// via a plain, invisible `NSView` that installs a local key-event monitor.
private struct KeyCaptureView: NSViewRepresentable {
    var onUp: () -> Void
    var onDown: () -> Void
    var onEnter: () -> Void

    func makeNSView(context: Context) -> NSView {
        let view = KeyHandlingView()
        view.onUp = onUp
        view.onDown = onDown
        view.onEnter = onEnter
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        guard let view = nsView as? KeyHandlingView else { return }
        view.onUp = onUp
        view.onDown = onDown
        view.onEnter = onEnter
    }

    final class KeyHandlingView: NSView {
        var onUp: (() -> Void)?
        var onDown: (() -> Void)?
        var onEnter: (() -> Void)?
        private var monitor: Any?

        override func viewDidMoveToWindow() {
            super.viewDidMoveToWindow()
            monitor.map(NSEvent.removeMonitor)
            monitor = nil
            guard window != nil else { return }
            monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
                guard let self, self.window != nil else { return event }
                switch event.keyCode {
                case 126: self.onUp?(); return nil
                case 125: self.onDown?(); return nil
                default: return event
                }
            }
        }

        deinit {
            monitor.map(NSEvent.removeMonitor)
        }
    }
}
