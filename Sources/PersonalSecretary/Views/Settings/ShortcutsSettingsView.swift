import SwiftUI

struct ShortcutsSettingsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Shortcuts").font(.system(size: 18, weight: .semibold)).padding(.bottom, 18)
            SettingsRow(label: "Quick Capture") {
                Text("⌥ Space")
                    .font(.system(size: 12))
                    .foregroundStyle(DT.Color.textSecondary)
                    .padding(.horizontal, 10).padding(.vertical, 5)
                    .background(DT.Color.sidebarBackground)
                    .clipShape(RoundedRectangle(cornerRadius: DT.Radius.sm, style: .continuous))
            }
            SettingsRow(label: "Global Search", showDivider: false) {
                Text("⌘ K")
                    .font(.system(size: 12))
                    .foregroundStyle(DT.Color.textSecondary)
                    .padding(.horizontal, 10).padding(.vertical, 5)
                    .background(DT.Color.sidebarBackground)
                    .clipShape(RoundedRectangle(cornerRadius: DT.Radius.sm, style: .continuous))
            }
        }
    }
}
