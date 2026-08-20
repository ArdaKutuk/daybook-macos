import SwiftUI

struct TopBarView: View {
    @Environment(AppState.self) private var appState
    @State private var showQuickPopover = false

    var body: some View {
        @Bindable var appState = appState

        HStack(spacing: 8) {
            Spacer()
            SearchFieldButton(action: { appState.showGlobalSearch = true })
            QuickActionButton(
                systemImage: "plus",
                background: DT.Color.accentSoftBackground,
                foreground: DT.Color.accentSoftText,
                action: { appState.showQuickCapture = true }
            )
            .help("Quick Capture (⌥Space)")
            QuickActionButton(
                systemImage: "chevron.down",
                action: { showQuickPopover.toggle() }
            )
            .help("Today at a Glance")
            .popover(isPresented: $showQuickPopover, arrowEdge: .top) {
                MenuBarPopoverView()
                    .frame(width: 250)
            }
        }
        .padding(.horizontal, 28)
        .frame(height: DT.Size.topBarHeight)
        .background(DT.Color.appBackground)
        .overlay(alignment: .bottom) {
            Rectangle().fill(DT.Color.sidebarBorder).frame(height: 1)
        }
    }
}
