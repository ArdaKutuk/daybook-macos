import SwiftUI

struct FocusSettingsView: View {
    @AppStorage(SettingsKeys.focusDurationMinutes) private var focusDuration = 25
    @AppStorage(SettingsKeys.breakDurationMinutes) private var breakDuration = 5

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Focus").font(.system(size: 18, weight: .semibold)).padding(.bottom, 18)

            VStack(alignment: .leading, spacing: 8) {
                Text("Focus Duration — \(focusDuration) min").font(.system(size: 13))
                Slider(value: Binding(get: { Double(focusDuration) }, set: { focusDuration = Int($0) }), in: 5...90, step: 5)
            }
            .padding(.vertical, 14)
            .overlay(alignment: .bottom) { Rectangle().fill(DT.Color.divider).frame(height: 1) }

            VStack(alignment: .leading, spacing: 8) {
                Text("Break Duration — \(breakDuration) min").font(.system(size: 13))
                Slider(value: Binding(get: { Double(breakDuration) }, set: { breakDuration = Int($0) }), in: 1...30, step: 1)
            }
            .padding(.vertical, 14)
        }
    }
}
