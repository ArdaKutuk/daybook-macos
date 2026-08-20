import SwiftUI

/// Small rounded-square icon button used in the top bar (Quick Capture "+",
/// Menu Bar popover toggle "▾") and menu-bar popover quick actions.
struct QuickActionButton: View {
    var systemImage: String
    var background: Color = DT.Color.sidebarBackground
    var foreground: Color = DT.Color.textSecondary
    var action: () -> Void

    @State private var isHovering = false

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(foreground)
                .frame(width: DT.Size.quickActionButton, height: DT.Size.quickActionButton)
                .background(isHovering ? background.opacity(0.7) : background)
                .clipShape(RoundedRectangle(cornerRadius: DT.Radius.md, style: .continuous))
        }
        .buttonStyle(.plain)
        .onHover { isHovering = $0 }
    }
}
