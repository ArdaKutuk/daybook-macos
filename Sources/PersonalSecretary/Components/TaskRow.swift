import SwiftUI

/// A single task row. Used both in compact form (Today dashboard, max 6
/// items, no delete affordance) and full form (Tasks list, with description
/// preview + delete), matching the two row variants in the prototype.
struct TaskRow: View {
    enum Style { case compact, full }

    var task: TaskItem
    var style: Style = .full
    var onToggle: () -> Void
    var onDelete: (() -> Void)? = nil

    @State private var isHovering = false

    var body: some View {
        HStack(spacing: style == .compact ? 12 : 14) {
            CheckCircle(isChecked: task.isCompleted, action: onToggle)

            VStack(alignment: .leading, spacing: 2) {
                Text(task.title)
                    .font(.system(size: 13.5))
                    .foregroundStyle(task.isCompleted ? DT.Color.textPlaceholder : DT.Color.textPrimary)
                    .strikethrough(task.isCompleted)
                    .lineLimit(1)
                if style == .full, !task.taskDescription.isEmpty {
                    Text(task.taskDescription)
                        .font(.system(size: 12))
                        .foregroundStyle(DT.Color.textTertiary)
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Text(task.dueTime?.timeHHmm ?? "—")
                .font(.system(size: 12))
                .foregroundStyle(DT.Color.textTertiary)
                .frame(width: style == .compact ? 52 : 60, alignment: .leading)

            if style == .full {
                PriorityBadge(priority: task.priority)
            } else {
                Circle()
                    .fill(DT.PriorityStyle.dot(task.priority))
                    .frame(width: DT.Size.navDot, height: DT.Size.navDot)
            }

            CategoryChip(category: task.category)

            if style == .full, let onDelete {
                Button(action: onDelete) {
                    Text("Delete")
                        .font(.system(size: 12))
                        .foregroundStyle(isHovering ? DT.Color.dangerHover : DT.Color.textPlaceholder)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, style == .compact ? 6 : 20)
        .padding(.vertical, style == .compact ? 9 : 14)
        .hoverHighlight()
        .onHover { isHovering = $0 }
    }
}
