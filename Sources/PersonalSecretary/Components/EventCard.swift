import SwiftUI

/// Small calendar-day event chip, and the larger event detail panel shown
/// next to the month/week/day grid when an event is selected.
struct EventChip: View {
    var title: String
    var background: Color
    var foreground: Color
    var action: () -> Void

    var body: some View {
        Text(title)
            .font(.system(size: 10))
            .lineLimit(1)
            .truncationMode(.tail)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(background)
            .foregroundStyle(foreground)
            .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
            .contentShape(Rectangle())
            .onTapGesture(perform: action)
    }
}

struct EventDetailPanel: View {
    var title: String
    var timeRange: String
    var location: String
    var notes: String
    var reminderLabel: String
    var onClose: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(DT.Color.textPrimary)
                Spacer()
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 13))
                        .foregroundStyle(DT.Color.textTertiary)
                }
                .buttonStyle(.plain)
            }
            Text(timeRange)
                .font(.system(size: 13))
                .foregroundStyle(DT.Color.textSecondary)
                .padding(.top, DT.Spacing.md)
            if !location.isEmpty {
                Label(location, systemImage: "mappin.and.ellipse")
                    .font(.system(size: 13))
                    .foregroundStyle(DT.Color.textSecondary)
                    .padding(.top, DT.Spacing.smd)
            }
            if !notes.isEmpty {
                Text(notes)
                    .font(.system(size: 13))
                    .foregroundStyle(DT.Color.textTertiary)
                    .lineSpacing(4)
                    .padding(.top, DT.Spacing.mdl)
            }
            Text("Reminder: \(reminderLabel)")
                .font(.system(size: 12))
                .foregroundStyle(DT.Color.textPlaceholder)
                .padding(.top, DT.Spacing.lg)
                .padding(.top, DT.Spacing.lg)
                .overlay(alignment: .top) {
                    Rectangle().fill(DT.Color.divider).frame(height: 1)
                }
        }
        .padding(DT.Spacing.xl + 2)
        .frame(width: 280, alignment: .leading)
        .background(DT.Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DT.Radius.card, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: DT.Radius.card, style: .continuous)
                .stroke(DT.Color.cardBorder, lineWidth: 1)
        )
    }
}
