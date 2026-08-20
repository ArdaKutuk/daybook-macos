import Foundation
import Observation
import UserNotifications

/// Central place for scheduling/cancelling local notifications (task
/// reminders, routine reminders, event reminders, focus completion). All
/// scheduling calls are safe to make even before permission is granted or if
/// it was denied — they simply become no-ops, per the "graceful degradation"
/// requirement.
@Observable
final class NotificationService {
    enum AuthorizationState {
        case notDetermined, authorized, denied
    }

    private(set) var authorizationState: AuthorizationState = .notDetermined
    private let center = UNUserNotificationCenter.current()

    enum Category: String {
        case task, routine, event, focus
    }

    init() {
        refreshAuthorization()
    }

    func refreshAuthorization() {
        center.getNotificationSettings { [weak self] settings in
            let state: AuthorizationState
            switch settings.authorizationStatus {
            case .notDetermined: state = .notDetermined
            case .authorized, .provisional, .ephemeral: state = .authorized
            default: state = .denied
            }
            Task { @MainActor [weak self] in self?.authorizationState = state }
        }
    }

    @MainActor
    func requestAuthorization() async {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            authorizationState = granted ? .authorized : .denied
        } catch {
            authorizationState = .denied
        }
    }

    private func identifier(_ category: Category, _ id: UUID) -> String { "\(category.rawValue)-\(id.uuidString)" }

    func scheduleTaskReminder(taskID: UUID, title: String, fireDate: Date) {
        guard AppSettings.notifTasksEnabled else { return }
        schedule(identifier: identifier(.task, taskID), title: "Task Reminder", body: title, fireDate: fireDate)
    }

    func cancelTaskReminder(taskID: UUID) {
        cancel(identifier: identifier(.task, taskID))
    }

    func scheduleRoutineReminder(routineID: UUID, name: String, fireDate: Date) {
        guard AppSettings.notifRoutinesEnabled else { return }
        schedule(identifier: identifier(.routine, routineID), title: "Routine Reminder", body: name, fireDate: fireDate, repeats: true)
    }

    func cancelRoutineReminder(routineID: UUID) {
        cancel(identifier: identifier(.routine, routineID))
    }

    func scheduleEventReminder(eventID: UUID, title: String, fireDate: Date) {
        schedule(identifier: identifier(.event, eventID), title: "Upcoming Event", body: title, fireDate: fireDate)
    }

    func cancelEventReminder(eventID: UUID) {
        cancel(identifier: identifier(.event, eventID))
    }

    func notifyFocusSessionCompleted(taskLabel: String) {
        guard AppSettings.notifFocusEnabled else { return }
        let request = makeRequest(
            identifier: "focus-complete-\(UUID().uuidString)",
            title: "Focus Session Complete",
            body: "Nice work — \(taskLabel) session finished.",
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        )
        center.add(request, withCompletionHandler: nil)
    }

    private func schedule(identifier: String, title: String, body: String, fireDate: Date, repeats: Bool = false) {
        guard authorizationState == .authorized, fireDate > .now else { return }
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: fireDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: repeats)
        let request = makeRequest(identifier: identifier, title: title, body: body, trigger: trigger)
        center.add(request, withCompletionHandler: nil)
    }

    private func makeRequest(identifier: String, title: String, body: String, trigger: UNNotificationTrigger) -> UNNotificationRequest {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        return UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
    }

    private func cancel(identifier: String) {
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
    }
}
