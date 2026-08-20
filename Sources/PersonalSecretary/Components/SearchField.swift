import SwiftUI

/// The rounded pill search field used both as the top-bar "Search your day…"
/// trigger and inside search/filter bars.
struct SearchFieldButton: View {
    var placeholder: String = "Search your day..."
    var shortcutLabel: String? = "⌘K"
    var action: () -> Void

    @State private var isHovering = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: DT.Spacing.smd) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 12))
                Text(placeholder)
                if let shortcutLabel {
                    Text(shortcutLabel)
                        .foregroundStyle(DT.Color.textPlaceholder)
                        .padding(.leading, DT.Spacing.xs)
                }
            }
            .font(.system(size: 13))
            .foregroundStyle(DT.Color.textTertiary)
            .padding(.horizontal, DT.Spacing.mdl)
            .padding(.vertical, DT.Spacing.smd)
            .background(isHovering ? DT.Color.sidebarBorder.opacity(0.6) : DT.Color.sidebarBackground)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(DT.Color.sidebarBorder, lineWidth: 1))
        }
        .buttonStyle(.plain)
        .onHover { isHovering = $0 }
    }
}

/// Plain bordered text field used for inline search/filter inputs (Tasks
/// search, New Task title, etc).
struct AppTextField: View {
    var placeholder: String
    @Binding var text: String
    var isMultiline: Bool = false

    var body: some View {
        Group {
            if isMultiline {
                TextEditor(text: $text)
                    .scrollContentBackground(.hidden)
            } else {
                TextField(placeholder, text: $text)
                    .textFieldStyle(.plain)
            }
        }
        .font(.system(size: 13))
        .padding(.horizontal, DT.Spacing.mdl)
        .padding(.vertical, DT.Spacing.smd + 1)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: DT.Radius.md, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: DT.Radius.md, style: .continuous)
                .stroke(DT.Color.cardBorder, lineWidth: 1)
        )
    }
}
