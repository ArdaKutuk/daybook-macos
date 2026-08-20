import SwiftData
import SwiftUI

/// Self-contained (no `AppState`/environment dependency) so it can be hosted
/// both as an in-window overlay and inside the floating `NSPanel` summoned
/// by the global ⌥Space hotkey.
struct QuickCaptureView: View {
    enum CaptureType: String, CaseIterable { case task = "Task", note = "Note" }

    let context: ModelContext
    let notificationService: NotificationService
    let onDismiss: () -> Void

    @State private var text = ""
    @State private var type: CaptureType = .task
    @State private var date = Date.now
    @State private var time = Date.now
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Quick Capture")
                .font(.system(size: 15, weight: .semibold))
                .padding(.bottom, 12)

            TextField("What do you want to remember?", text: $text)
                .textFieldStyle(.plain)
                .font(.system(size: 14))
                .padding(.horizontal, 14)
                .padding(.vertical, 11)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: DT.Radius.mdl, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: DT.Radius.mdl, style: .continuous).stroke(DT.Color.cardBorder, lineWidth: 1))
                .focused($isFocused)
                .onSubmit(submit)
                .padding(.bottom, 12)

            SegmentedPill(options: CaptureType.allCases, label: \.rawValue, selection: $type, activeColor: DT.Color.textPrimary)

            if type == .task {
                HStack(spacing: 8) {
                    DatePicker("", selection: $date, displayedComponents: .date).labelsHidden()
                    DatePicker("", selection: $time, displayedComponents: .hourAndMinute).labelsHidden()
                }
                .padding(.top, 12)
            }

            Text("Press Enter to save · Esc to close")
                .font(.system(size: 11))
                .foregroundStyle(DT.Color.textPlaceholder)
                .padding(.top, 14)
        }
        .padding(22)
        .frame(width: 420)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: DT.Radius.modalSmall, style: .continuous))
        .shadow(color: DT.Shadow.modal.color, radius: DT.Shadow.modal.radius, y: DT.Shadow.modal.y)
        .onAppear { isFocused = true }
        .onExitCommand(perform: onDismiss)
    }

    private func submit() {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { onDismiss(); return }

        switch type {
        case .task:
            let task = TaskItem(title: trimmed, dueDate: date, dueTime: time)
            context.insert(task)
        case .note:
            let note = Note(title: trimmed)
            context.insert(note)
        }
        try? context.save()
        text = ""
        onDismiss()
    }
}
