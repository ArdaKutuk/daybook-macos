import XCTest
@testable import PersonalSecretary

@MainActor
final class FocusDurationTests: XCTestCase {
    func testClassicPresetIsTwentyFiveMinutes() {
        let manager = FocusTimerManager(notificationService: NotificationService())
        manager.applyPreset(.classic)
        XCTAssertEqual(manager.formattedRemaining, "25:00")
    }

    func testLongPresetIsFiftyMinutes() {
        let manager = FocusTimerManager(notificationService: NotificationService())
        manager.applyPreset(.long)
        XCTAssertEqual(manager.formattedRemaining, "50:00")
    }

    func testSetDurationIsIgnoredWhileRunning() {
        let manager = FocusTimerManager(notificationService: NotificationService())
        manager.applyPreset(.classic)
        manager.start()
        manager.setDuration(minutes: 10)
        XCTAssertEqual(manager.formattedRemaining, "25:00", "Duration shouldn't change mid-session")
        manager.pause()
    }

    func testStopResetsRemainingToFullDuration() {
        let manager = FocusTimerManager(notificationService: NotificationService())
        manager.applyPreset(.classic)
        manager.start()
        manager.pause()
        manager.stop()
        XCTAssertEqual(manager.formattedRemaining, "25:00")
        XCTAssertFalse(manager.isRunning)
    }

    func testFocusTotalSecondsOnlyIncludesToday() {
        let now = Date.now
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: now)!
        let todaySession = FocusSession(startDate: now, endDate: now.addingTimeInterval(1500), duration: 1500, completed: true)
        let oldSession = FocusSession(startDate: yesterday, endDate: yesterday.addingTimeInterval(3000), duration: 3000, completed: true)

        let total = DashboardViewModel.focusTotalSeconds([todaySession, oldSession], date: now)

        XCTAssertEqual(total, 1500)
    }
}
