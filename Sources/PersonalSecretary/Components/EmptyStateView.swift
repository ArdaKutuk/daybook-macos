import SwiftUI

/// Centered empty-state block used across Tasks / Notes / Routines / Files
/// when a list has no items: icon tile, title, subtitle, optional CTA.
struct EmptyStateView: View {
    var symbol: String
    var iconBackground: Color
    var iconForeground: Color
    var title: String
    var subtitle: String
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        VStack(spacing: DT.Spacing.mdl) {
            ZStack {
                RoundedRectangle(cornerRadius: DT.Radius.cardSmall, style: .continuous)
                    .fill(iconBackground)
                    .frame(width: 56, height: 56)
                Image(systemName: symbol)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(iconForeground)
            }
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(DT.Color.textPrimary)
            Text(subtitle)
                .font(.system(size: 13))
                .foregroundStyle(DT.Color.textTertiary)
            if let actionTitle, let action {
                AppButton(title: actionTitle, style: .primary, action: action)
                    .padding(.top, DT.Spacing.xs)
            }
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }
}
