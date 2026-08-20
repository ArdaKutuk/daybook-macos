import SwiftUI

/// Small rounded category tag ("Work", "Personal", ...) with per-category
/// background/text color taken from `DT.CategoryStyle`.
struct CategoryChip: View {
    var category: TaskCategory

    var body: some View {
        Text(category.rawValue)
            .font(.system(size: 11))
            .foregroundStyle(DT.CategoryStyle.text(category))
            .padding(.horizontal, DT.Spacing.mdl - 2)
            .padding(.vertical, DT.Spacing.xs - 1)
            .background(DT.CategoryStyle.background(category))
            .clipShape(Capsule())
    }
}

/// Small dot + label priority indicator ("● High").
struct PriorityBadge: View {
    var priority: Priority
    var showLabel: Bool = true

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(DT.PriorityStyle.dot(priority))
                .frame(width: DT.Size.navDot, height: DT.Size.navDot)
            if showLabel {
                Text(priority.rawValue)
                    .font(.system(size: 11))
                    .foregroundStyle(DT.PriorityStyle.text(priority))
            }
        }
    }
}
