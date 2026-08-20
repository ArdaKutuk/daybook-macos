import SwiftUI

/// The rounded segmented control used for Task tabs, Calendar view mode,
/// Focus presets, Settings appearance, and Overview range.
struct SegmentedPill<Option: Hashable>: View {
    let options: [Option]
    let label: (Option) -> String
    @Binding var selection: Option
    var activeColor: Color = DT.Color.accent
    var activeTextColor: Color = .white

    var body: some View {
        HStack(spacing: 4) {
            ForEach(options, id: \.self) { option in
                let isActive = option == selection
                Text(label(option))
                    .font(.system(size: 13, weight: isActive ? .semibold : .regular))
                    .foregroundStyle(isActive ? activeTextColor : DT.Color.textSecondary)
                    .padding(.horizontal, DT.Spacing.xl - 2)
                    .padding(.vertical, DT.Spacing.smd)
                    .background(isActive ? activeColor : .clear)
                    .clipShape(RoundedRectangle(cornerRadius: DT.Radius.md, style: .continuous))
                    .contentShape(Rectangle())
                    .onTapGesture { selection = option }
            }
        }
        .padding(4)
        .background(DT.Color.pillTrackBackground)
        .clipShape(RoundedRectangle(cornerRadius: DT.Radius.lg, style: .continuous))
    }
}
