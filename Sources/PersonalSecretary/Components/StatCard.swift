import SwiftUI

/// Overview screen metric tile ("Tasks Completed", "24" style).
struct StatCard: View {
    var label: String
    var value: String

    var body: some View {
        CardContainer(padding: DT.Spacing.xl) {
            VStack(alignment: .leading, spacing: 6) {
                Text(label)
                    .font(.system(size: 12))
                    .foregroundStyle(DT.Color.textTertiary)
                Text(value)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(DT.Color.textPrimary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

/// Dashboard "Daily Progress" style card with a labeled progress bar.
struct ProgressCard: View {
    var label: String
    var valueText: String
    var progress: Double
    var tint: Color = DT.Color.mintDot

    var body: some View {
        CardContainer {
            VStack(alignment: .leading, spacing: 0) {
                CardLabel(text: label)
                    .padding(.bottom, DT.Spacing.lg)
                Text(valueText)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(DT.Color.textPrimary)
                GeometryReader { proxy in
                    ZStack(alignment: .leading) {
                        Capsule().fill(DT.Color.sidebarBackground)
                        Capsule().fill(tint)
                            .frame(width: proxy.size.width * max(0, min(1, progress)))
                    }
                }
                .frame(height: 8)
                .padding(.top, DT.Spacing.lg)
            }
        }
    }
}
