import SwiftData
import SwiftUI

struct NewEventSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(NotificationService.self) private var notificationService

    var defaultDate: Date
    var onDismiss: () -> Void

    @State private var title = ""
    @State private var location = ""
    @State private var notes = ""
    @State private var startDate: Date
    @State private var endDate: Date
    @State private var reminder: ReminderOffset = .none

    init(defaultDate: Date, onDismiss: @escaping () -> Void) {
        self.defaultDate = defaultDate
        self.onDismiss = onDismiss
        _startDate = State(initialValue: defaultDate)
        _endDate = State(initialValue: defaultDate.addingTimeInterval(3600))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("New Event").font(.system(size: 17, weight: .semibold)).padding(.bottom, 18)
            AppTextField(placeholder: "Title", text: $title).padding(.bottom, 10)
            AppTextField(placeholder: "Location", text: $location).padding(.bottom, 10)
            HStack(spacing: 10) {
                DatePicker("Start", selection: $startDate)
                DatePicker("End", selection: $endDate)
            }
            .labelsHidden()
            .padding(.bottom, 10)
            Picker("Reminder", selection: $reminder) {
                ForEach(ReminderOffset.allCases) { Text($0.rawValue).tag($0) }
            }
            .labelsHidden()
            .padding(.bottom, 16)
            HStack {
                Spacer()
                AppButton(title: "Cancel", style: .text, action: onDismiss)
                AppButton(title: "Create", style: .primary, action: create)
            }
        }
        .padding(28)
        .frame(width: 420)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: DT.Radius.modal, style: .continuous))
        .shadow(color: DT.Shadow.modal.color, radius: DT.Shadow.modal.radius, y: DT.Shadow.modal.y)
    }

    private func create() {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { onDismiss(); return }
        let event = LocalEvent(title: trimmed, eventDescription: notes, startDate: startDate, endDate: endDate, location: location, reminder: reminder)
        modelContext.insert(event)
        try? modelContext.save()
        if let minutes = reminder.minutesBefore {
            notificationService.scheduleEventReminder(eventID: event.id, title: event.title, fireDate: startDate.addingTimeInterval(TimeInterval(-minutes * 60)))
        }
        onDismiss()
    }
}
