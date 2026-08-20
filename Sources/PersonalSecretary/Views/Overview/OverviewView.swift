import Charts
import SwiftData
import SwiftUI

struct OverviewView: View {
    @Query private var tasks: [TaskItem]
    @Query private var routines: [Routine]
    @Query private var sessions: [FocusSession]

    @State private var range: OverviewRange = .week

    private var stats: OverviewStats {
        OverviewViewModel.computeStats(tasks: tasks, routines: routines, sessions: sessions, range: range)
    }

    private let columns = [GridItem(.adaptive(minimum: 180), spacing: 16)]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Overview").font(DT.Font.sectionTitle).foregroundStyle(DT.Color.textPrimary)
                Spacer()
                SegmentedPill(options: OverviewRange.allCases, label: \.label, selection: $range)
            }

            LazyVGrid(columns: columns, spacing: 16) {
                StatCard(label: "Tasks Completed", value: "\(stats.tasksCompleted)")
                StatCard(label: "Completion Rate", value: "\(stats.completionRatePct)%")
                StatCard(label: "Focus Time", value: stats.focusTimeLabel)
                StatCard(label: "Focus Sessions", value: "\(stats.focusSessions)")
                StatCard(label: "Routine Completion", value: "\(stats.routineCompletionPct)%")
                StatCard(label: "Most Productive Day", value: stats.mostProductiveDay)
            }
            .padding(.top, 24)

            CardContainer {
                VStack(alignment: .leading, spacing: 0) {
                    CardLabel(text: "Tasks Completed per Day").padding(.bottom, 18)
                    let bars = Array(stats.chartBars.enumerated())
                    // Plotted by integer index (always unique) rather than by
                    // label text, so same-named categories (e.g. repeated
                    // weekday abbreviations) never collapse into one bar.
                    Chart(bars, id: \.offset) { index, bar in
                        BarMark(x: .value("Day", index), y: .value("Completed", bar.count))
                            .foregroundStyle(DT.Color.chartBar)
                            .cornerRadius(4)
                    }
                    .frame(height: 120)
                    .chartYAxis(.hidden)
                    .chartXAxis {
                        let step = range == .week ? 1 : 5
                        AxisMarks(values: bars.map(\.offset).filter { $0 % step == 0 }) { value in
                            if let index = value.as(Int.self), bars.indices.contains(index) {
                                AxisValueLabel(bars[index].element.label)
                                    .font(.system(size: 10))
                                    .foregroundStyle(DT.Color.textTertiary)
                            }
                        }
                    }
                }
            }
            .padding(.top, 26)
        }
    }
}
