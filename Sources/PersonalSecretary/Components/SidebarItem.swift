import SwiftUI

/// A single sidebar navigation row: colored dot + label, highlighted white
/// pill with a soft shadow when active — mirrors `navStyle()` in the
/// prototype exactly.
struct SidebarItem: View {
    var title: String
    var dotColor: Color
    var isActive: Bool
    var action: () -> Void

    @State private var isHovering = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Circle()
                    .fill(dotColor)
                    .frame(width: DT.Size.navDot, height: DT.Size.navDot)
                Text(title)
                    .font(.system(size: 13.5, weight: isActive ? .semibold : .regular))
                    .foregroundStyle(isActive ? DT.Color.textPrimary : DT.Color.textSecondary)
                Spacer(minLength: 0)
            }
            .padding(.horizontal, DT.Spacing.mdl)
            .padding(.vertical, DT.Spacing.smd + 1)
            .background(isActive ? Color.white : (isHovering ? Color.white.opacity(0.5) : .clear))
            .clipShape(RoundedRectangle(cornerRadius: DT.Radius.md, style: .continuous))
            .shadow(color: isActive ? DT.Shadow.card.color : .clear, radius: isActive ? 2 : 0, y: isActive ? 1 : 0)
        }
        .buttonStyle(.plain)
        .onHover { isHovering = $0 }
    }
}
