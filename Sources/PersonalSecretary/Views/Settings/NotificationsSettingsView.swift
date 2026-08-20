import SwiftUI

struct NotificationsSettingsView: View {
    @Environment(NotificationService.self) private var notificationService
    @AppStorage(SettingsKeys.notifTasksEnabled) private var notifTasks = true
    @AppStorage(SettingsKeys.notifRoutinesEnabled) private var notifRoutines = true
    @AppStorage(SettingsKeys.notifFocusEnabled) private var notifFocus = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Notifications").font(.system(size: 18, weight: .semibold)).padding(.bottom, 18)

            if notificationService.authorizationState == .denied {
                Text("Notifications are disabled for Daybook in System Settings.")
                    .font(.system(size: 12))
                    .foregroundStyle(DT.Color.textPlaceholder)
                    .padding(.bottom, 12)
            }

            SettingsRow(label: "Tasks") {
                ToggleSwitch(isOn: $notifTasks).onChange(of: notifTasks) { _, _ in requestIfNeeded() }
            }
            SettingsRow(label: "Routines") {
                ToggleSwitch(isOn: $notifRoutines).onChange(of: notifRoutines) { _, _ in requestIfNeeded() }
            }
            SettingsRow(label: "Focus", showDivider: false) {
                ToggleSwitch(isOn: $notifFocus).onChange(of: notifFocus) { _, _ in requestIfNeeded() }
            }
        }
        .onAppear { notificationService.refreshAuthorization() }
    }

    private func requestIfNeeded() {
        guard notificationService.authorizationState == .notDetermined else { return }
        Task { await notificationService.requestAuthorization() }
    }
}
