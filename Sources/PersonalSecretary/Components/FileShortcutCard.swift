import SwiftUI

struct FileShortcutCard: View {
    var shortcut: FileShortcut
    var onOpen: () -> Void
    var onRemove: () -> Void

    @State private var isHoveringRemove = false

    private var extLabel: String {
        if shortcut.type == .folder { return "DIR" }
        let ext = (shortcut.displayName as NSString).pathExtension.uppercased()
        return ext.isEmpty ? "DOC" : String(ext.prefix(3))
    }

    private var typeLabel: String {
        shortcut.type == .folder ? "Folder" : "File"
    }

    private var palette: (bg: Color, fg: Color) {
        DT.routineIconPalette[abs(shortcut.displayName.hashValue) % DT.routineIconPalette.count]
    }

    var body: some View {
        HStack(spacing: DT.Spacing.mdl) {
            ZStack {
                RoundedRectangle(cornerRadius: DT.Radius.md + 1, style: .continuous)
                    .fill(palette.bg)
                    .frame(width: 38, height: 38)
                Text(extLabel)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(palette.fg)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(shortcut.displayName)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(DT.Color.textPrimary)
                    .lineLimit(1)
                Text(shortcut.isStale ? "File not found" : typeLabel)
                    .font(.system(size: 11))
                    .foregroundStyle(shortcut.isStale ? DT.Color.dangerText : DT.Color.textTertiary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            Button("Remove", action: onRemove)
                .buttonStyle(.plain)
                .font(.system(size: 11))
                .foregroundStyle(isHoveringRemove ? DT.Color.dangerHover : DT.Color.textPlaceholder)
                .onHover { isHoveringRemove = $0 }
        }
        .padding(DT.Spacing.lgl)
        .background(DT.Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DT.Radius.cardSmall, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: DT.Radius.cardSmall, style: .continuous)
                .stroke(DT.Color.cardBorder, lineWidth: 1)
        )
        .contentShape(Rectangle())
        .onTapGesture(perform: onOpen)
    }
}
