import SwiftUI

/// Applies a background highlight on hover, matching the prototype's
/// `style-hover` rows (task rows, list items, popover actions, etc).
struct HoverHighlight: ViewModifier {
    var cornerRadius: CGFloat = DT.Radius.mdl
    var color: Color = DT.Color.appBackground
    @State private var isHovering = false

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(isHovering ? color : .clear)
            )
            .onHover { hovering in isHovering = hovering }
    }
}

extension View {
    func hoverHighlight(cornerRadius: CGFloat = DT.Radius.mdl, color: Color = DT.Color.appBackground) -> some View {
        modifier(HoverHighlight(cornerRadius: cornerRadius, color: color))
    }
}

/// A clickable "pill" or "tile" that darkens slightly on hover, used for
/// primary/secondary buttons throughout the design.
struct HoverOpacity: ViewModifier {
    @State private var isHovering = false
    var amount: Double = 0.85

    func body(content: Content) -> some View {
        content
            .opacity(isHovering ? amount : 1)
            .onHover { hovering in isHovering = hovering }
    }
}

extension View {
    func hoverOpacity(_ amount: Double = 0.85) -> some View {
        modifier(HoverOpacity(amount: amount))
    }
}
