import SwiftUI

/// The white, rounded, subtly-shadowed card used everywhere in the design
/// (dashboard tiles, task list, notes editor, etc).
struct CardContainer<Content: View>: View {
    var padding: CGFloat = DT.Spacing.xxl
    var radius: CGFloat = DT.Radius.card
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(padding)
            .background(DT.Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .stroke(DT.Color.cardBorder, lineWidth: 1)
            )
            .shadow(color: DT.Shadow.card.color, radius: DT.Shadow.card.radius, y: DT.Shadow.card.y)
    }
}
