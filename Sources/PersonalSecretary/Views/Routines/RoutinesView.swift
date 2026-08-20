import SwiftData
import SwiftUI

struct RoutinesView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppState.self) private var appState
    @Query(sort: \Routine.createdAt) private var allRoutines: [Routine]

    private var repository: RoutineRepository { RoutineRepository(context: modelContext) }
    private var todaysRoutines: [Routine] { DashboardViewModel.routinesScheduledToday(allRoutines) }

    private let columns = [GridItem(.adaptive(minimum: 230), spacing: 14)]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionHeader(title: "Routines") {
                AppButton(title: "New Routine", style: .primary) { appState.showRoutineSheet = true }
            }

            if allRoutines.isEmpty {
                EmptyStateView(
                    symbol: "arrow.triangle.2.circlepath",
                    iconBackground: DT.Color.mintBackground,
                    iconForeground: DT.Color.mintDot,
                    title: "No routines yet",
                    subtitle: "Build consistency one habit at a time.",
                    actionTitle: "New Routine",
                    action: { appState.showRoutineSheet = true }
                )
            } else {
                Text("Today's Routines")
                    .font(DT.Font.cardLabel)
                    .foregroundStyle(DT.Color.textSecondary)
                    .padding(.top, 26)
                    .padding(.bottom, 12)

                LazyVGrid(columns: columns, spacing: 14) {
                    ForEach(todaysRoutines) { routine in
                        RoutineRow(
                            routine: routine,
                            isCompletedToday: (routine.completions ?? []).contains { $0.date.isSameDay(as: .now) },
                            onToggle: { repository.toggleCompletion(for: routine, on: .now) }
                        )
                        .contextMenu {
                            Button("Delete Routine", role: .destructive) { repository.delete(routine) }
                        }
                    }
                }
            }
        }
    }
}
