import SwiftUI

struct AppearanceSettingsView: View {
    @AppStorage(SettingsKeys.appearance) private var appearance = AppearanceMode.light.rawValue

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Appearance").font(.system(size: 18, weight: .semibold)).padding(.bottom, 18)
            SegmentedPill(
                options: AppearanceMode.allCases,
                label: \.rawValue,
                selection: Binding(
                    get: { AppearanceMode(rawValue: appearance) ?? .light },
                    set: { appearance = $0.rawValue }
                ),
                activeColor: DT.Color.textPrimary
            )
            Text("Default: Light")
                .font(.system(size: 12))
                .foregroundStyle(DT.Color.textTertiary)
                .padding(.top, 12)
        }
    }
}
