import Foundation
import SwiftData

/// A user-created event, distinct from events read (read-only) from Apple
/// Calendar via EventKit (see `EKEvent` usage in `CalendarService`).
@Model
final class LocalEvent {
    var id: UUID = UUID()
    var title: String = ""
    var eventDescription: String = ""
    var startDate: Date = Date.now
    var endDate: Date = Date.now.addingTimeInterval(3600)
    var location: String = ""
    var reminderRaw: String = ReminderOffset.none.rawValue
    var createdAt: Date = Date.now

    init(
        id: UUID = UUID(),
        title: String,
        eventDescription: String = "",
        startDate: Date,
        endDate: Date,
        location: String = "",
        reminder: ReminderOffset = .none
    ) {
        self.id = id
        self.title = title
        self.eventDescription = eventDescription
        self.startDate = startDate
        self.endDate = endDate
        self.location = location
        self.reminderRaw = reminder.rawValue
        self.createdAt = .now
    }

    var reminder: ReminderOffset {
        get { ReminderOffset(rawValue: reminderRaw) ?? .none }
        set { reminderRaw = newValue.rawValue }
    }
}
