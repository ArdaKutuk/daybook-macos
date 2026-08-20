import SwiftData
import SwiftUI

enum SettingsTab: String, CaseIterable, Identifiable {
    case general = "General"
    case appearance = "Appearance"
    case focus = "Focus"
    case notifications = "Notifications"
    case shortcuts = "Shortcuts"
    case data = "Data"
    var id: String { rawValue }
}

struct SettingsView: View {
    @State private var tab: SettingsTab = .general

    var body: some View {
        HStack(alignment: .top, spacing: 32) {
            VStack(alignment: .leading, spacing: 2) {
                ForEach(SettingsTab.allCases) { t in
                    Text(t.rawValue)
                        .font(.system(size: 13, weight: t == tab ? .semibold : .regular))
                        .foregroundStyle(t == tab ? DT.Color.textPrimary : DT.Color.textSecondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 9)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(t == tab ? DT.Color.sidebarBackground : .clear)
                        .clipShape(RoundedRectangle(cornerRadius: DT.Radius.md, style: .continuous))
                        .contentShape(Rectangle())
                        .onTapGesture { tab = t }
                }
            }
            .frame(width: 170)

            Group {
                switch tab {
                case .general: GeneralSettingsView()
                case .appearance: AppearanceSettingsView()
                case .focus: FocusSettingsView()
                case .notifications: NotificationsSettingsView()
                case .shortcuts: ShortcutsSettingsView()
                case .data: DataSettingsView()
                }
            }
            .frame(maxWidth: 480, alignment: .leading)
        }
    }
}

/// A settings row: label on the left, arbitrary control on the right,
/// bottom divider — matches every row in Settings > General/Notifications.
struct SettingsRow<Control: View>: View {
    var label: String
    var showDivider: Bool = true
    @ViewBuilder var control: Control

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(label).font(.system(size: 13)).foregroundStyle(DT.Color.textPrimary)
                Spacer()
                control
            }
            .padding(.vertical, 14)
            if showDivider {
                Rectangle().fill(DT.Color.divider).frame(height: 1)
            }
        }
    }
}
