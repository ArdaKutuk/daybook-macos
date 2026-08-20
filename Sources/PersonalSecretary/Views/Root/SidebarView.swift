import SwiftUI

struct SidebarView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 10) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 9, style: .continuous)
                            .fill(DT.Color.accentDot)
                            .frame(width: DT.Size.logoSize, height: DT.Size.logoSize)
                        Text("D")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    Text("Daybook")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(DT.Color.textPrimary)
                }
                .padding(.horizontal, 8)
                .padding(.bottom, 22)
                .padding(.top, 6)

                ForEach(AppSection.primary) { section in
                    SidebarItem(
                        title: section.rawValue,
                        dotColor: section.dotColor,
                        isActive: appState.selectedSection == section,
                        action: { appState.navigate(to: section) }
                    )
                }
            }

            Spacer()

            VStack(alignment: .leading, spacing: 2) {
                SidebarItem(
                    title: AppSection.settings.rawValue,
                    dotColor: AppSection.settings.dotColor,
                    isActive: appState.selectedSection == .settings,
                    action: { appState.navigate(to: .settings) }
                )
                Text("Local data on this Mac")
                    .font(.system(size: 11))
                    .foregroundStyle(DT.Color.textPlaceholder)
                    .padding(.horizontal, 12)
                    .padding(.top, 8)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 20)
        .frame(width: DT.Size.sidebarWidth)
        .frame(maxHeight: .infinity)
        .background(DT.Color.sidebarBackground)
        .overlay(alignment: .trailing) {
            Rectangle().fill(DT.Color.sidebarBorder).frame(width: 1)
        }
    }
}
