import SwiftUI

/// Page-level title row: "Tasks" / "Calendar" / "Routines" ... with an
/// optional trailing action button, matching every feature screen's header.
struct SectionHeader<Trailing: View>: View {
    var title: String
    @ViewBuilder var trailing: Trailing

    var body: some View {
        HStack {
            Text(title)
                .font(DT.Font.sectionTitle)
                .foregroundStyle(DT.Color.textPrimary)
            Spacer()
            trailing
        }
    }
}

extension SectionHeader where Trailing == EmptyView {
    init(title: String) {
        self.title = title
        self.trailing = EmptyView()
    }
}

/// Small muted eyebrow label used above card content ("Today's Tasks",
/// "Upcoming Event", "Daily Progress", ...).
struct CardLabel: View {
    var text: String
    var body: some View {
        Text(text)
            .font(DT.Font.cardLabel)
            .foregroundStyle(DT.Color.textSecondary)
    }
}
