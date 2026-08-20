import SwiftUI

/// Start / Pause / Stop control row for the Focus timer.
struct TimerControl: View {
    var isRunning: Bool
    var onStart: () -> Void
    var onPause: () -> Void
    var onStop: () -> Void

    var body: some View {
        HStack(spacing: DT.Spacing.md) {
            if isRunning {
                AppButton(title: "Pause", style: .secondary, action: onPause)
            } else {
                AppButton(title: "Start", style: .primary, action: onStart)
            }
            AppButton(title: "Stop", style: .secondary, action: onStop)
        }
    }
}
