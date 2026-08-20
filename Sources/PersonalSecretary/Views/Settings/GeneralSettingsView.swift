import SwiftUI

struct GeneralSettingsView: View {
    @Environment(LaunchAtLoginService.self) private var launchAtLogin
    @AppStorage(SettingsKeys.startPage) private var startPage = StartPage.today.rawValue
    @AppStorage(SettingsKeys.dateFormat) private var dateFormat = AppDateFormat.mdy.rawValue
    @AppStorage(SettingsKeys.firstDayOfWeek) private var firstDay = FirstWeekday.sunday.rawValue
    @State private var errorMessage: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("General").font(.system(size: 18, weight: .semibold)).padding(.bottom, 18)

            SettingsRow(label: "Launch at Login") {
                ToggleSwitch(isOn: Binding(
                    get: { launchAtLogin.isEnabled },
                    set: { newValue in
                        launchAtLogin.setEnabled(newValue)
                        errorMessage = launchAtLogin.lastError
                    }
                ))
            }

            SettingsRow(label: "Start Page") {
                Picker("", selection: $startPage) {
                    ForEach(StartPage.allCases) { Text($0.rawValue).tag($0.rawValue) }
                }
                .labelsHidden()
                .frame(width: 140)
            }

            SettingsRow(label: "Date Format") {
                Picker("", selection: $dateFormat) {
                    ForEach(AppDateFormat.allCases) { Text($0.rawValue).tag($0.rawValue) }
                }
                .labelsHidden()
                .frame(width: 140)
            }

            SettingsRow(label: "First Day of Week", showDivider: false) {
                Picker("", selection: $firstDay) {
                    ForEach(FirstWeekday.allCases) { Text($0.rawValue).tag($0.rawValue) }
                }
                .labelsHidden()
                .frame(width: 140)
            }

            if let errorMessage {
                Text(errorMessage)
                    .font(.system(size: 12))
                    .foregroundStyle(DT.Color.dangerText)
                    .padding(.top, 10)
            }
        }
    }
}
