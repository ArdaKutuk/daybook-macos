import SwiftUI

/// Routine card used on the Routines grid: icon tile, name/schedule/streak,
/// trailing completion circle.
struct RoutineRow: View {
    var routine: Routine
    var isCompletedToday: Bool
    var onToggle: () -> Void

    private var palette: (bg: Color, fg: Color) {
        DT.routineIconPalette[routine.paletteIndex % DT.routineIconPalette.count]
    }

    var body: some View {
        HStack(spacing: DT.Spacing.lg) {
            ZStack {
                RoundedRectangle(cornerRadius: DT.Radius.md + 3, style: .continuous)
                    .fill(palette.bg)
                    .frame(width: DT.Size.iconTile, height: DT.Size.iconTile)
                Text(routine.symbol)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(palette.fg)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(routine.name)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(DT.Color.textPrimary)
                Text(routine.scheduleLabel)
                    .font(.system(size: 12))
                    .foregroundStyle(DT.Color.textTertiary)
                Text("\(routine.currentStreak) day streak")
                    .font(.system(size: 11))
                    .foregroundStyle(DT.Color.textPlaceholder)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            CheckCircle(isChecked: isCompletedToday, size: DT.Size.checkCircleLarge, action: onToggle)
        }
        .padding(DT.Spacing.lgl + 2)
        .background(DT.Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DT.Radius.card, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: DT.Radius.card, style: .continuous)
                .stroke(DT.Color.cardBorder, lineWidth: 1)
        )
    }
}
