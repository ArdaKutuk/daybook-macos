import SwiftUI

/// Primary/secondary/destructive button matching the design's rounded pill
/// buttons (e.g. "New Task", "Create", "Cancel", "Reset Data").
struct AppButton: View {
    enum Style {
        case primary
        case secondary
        case destructive
        case text
    }

    var title: String
    var style: Style = .primary
    var action: () -> Void

    @State private var isHovering = false

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: style == .text ? .regular : .medium))
                .foregroundStyle(foreground)
                .padding(.horizontal, style == .text ? DT.Spacing.mdl : DT.Spacing.xl)
                .padding(.vertical, style == .text ? DT.Spacing.smd : DT.Spacing.md + 0.5)
                .background(background)
                .clipShape(RoundedRectangle(cornerRadius: DT.Radius.mdl, style: .continuous))
        }
        .buttonStyle(.plain)
        .onHover { isHovering = $0 }
    }

    private var foreground: Color {
        switch style {
        case .primary: return .white
        case .secondary: return DT.Color.textPrimary
        case .destructive: return DT.Color.orangeText
        case .text: return DT.Color.textSecondary
        }
    }

    private var background: Color {
        switch style {
        case .primary: return isHovering ? DT.Color.accentHover : DT.Color.accent
        case .secondary: return DT.Color.sidebarBackground
        case .destructive: return DT.Color.orangeBackground
        case .text: return .clear
        }
    }
}
