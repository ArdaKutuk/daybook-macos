import Foundation
import Observation
import SwiftData

/// Drives the Pomodoro-style focus timer independent of any View, so the
/// timer keeps ticking correctly across view updates / tab switches and app
/// lifecycle changes (sleep/wake, window close) instead of being tied to a
/// SwiftUI view's lifetime.
@Observable
@MainActor
final class FocusTimerManager {
    private(set) var isRunning = false
    private(set) var remainingSeconds: Int
    private(set) var durationSeconds: Int
    var preset: FocusPreset = .classic
    var linkedTask: TaskItem?
    var taskLabel: String = ""

    private var timer: Timer?
    private var sessionStart: Date?
    private let notificationService: NotificationService

    /// Called with the finished session's start/end/duration/completed so the
    /// owner can persist a `FocusSession` — this manager doesn't touch
    /// SwiftData directly, keeping timer logic decoupled from persistence.
    var onSessionFinished: ((_ start: Date, _ end: Date, _ duration: TimeInterval, _ completed: Bool, _ task: TaskItem?, _ label: String) -> Void)?

    init(notificationService: NotificationService) {
        let minutes = AppSettings.focusDurationMinutes
        self.durationSeconds = minutes * 60
        self.remainingSeconds = minutes * 60
        self.notificationService = notificationService
    }

    func applyPreset(_ preset: FocusPreset) {
        guard !isRunning else { return }
        self.preset = preset
        switch preset {
        case .classic: setDuration(minutes: 25)
        case .long: setDuration(minutes: 50)
        case .custom: setDuration(minutes: AppSettings.focusDurationMinutes)
        }
    }

    func setDuration(minutes: Int) {
        guard !isRunning else { return }
        durationSeconds = minutes * 60
        remainingSeconds = minutes * 60
    }

    func start() {
        guard !isRunning else { return }
        if remainingSeconds <= 0 { remainingSeconds = durationSeconds }
        if sessionStart == nil { sessionStart = .now }
        isRunning = true
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.tick() }
        }
    }

    func pause() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }

    func stop() {
        finishSession(completed: false)
        remainingSeconds = durationSeconds
        sessionStart = nil
    }

    private func tick() {
        guard isRunning else { return }
        guard remainingSeconds > 0 else {
            finishSession(completed: true)
            return
        }
        remainingSeconds -= 1
        if remainingSeconds == 0 {
            finishSession(completed: true)
        }
    }

    private func finishSession(completed: Bool) {
        timer?.invalidate()
        timer = nil
        isRunning = false
        guard let start = sessionStart else { return }
        let end = Date.now
        let elapsed = completed ? TimeInterval(durationSeconds) : end.timeIntervalSince(start)
        guard elapsed >= 1 else {
            sessionStart = nil
            return
        }
        let label = taskLabel.isEmpty ? (linkedTask?.title ?? "Focus Session") : taskLabel
        onSessionFinished?(start, end, elapsed, completed, linkedTask, label)
        if completed {
            notificationService.notifyFocusSessionCompleted(taskLabel: label)
        }
        sessionStart = nil
    }

    var formattedRemaining: String {
        let m = remainingSeconds / 60
        let s = remainingSeconds % 60
        return String(format: "%02d:%02d", m, s)
    }
}
