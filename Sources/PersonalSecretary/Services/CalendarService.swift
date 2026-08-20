import EventKit
import Foundation
import Observation

/// A read-only, presentation-friendly copy of an `EKEvent`. We never hand
/// `EKEvent` itself to the UI layer so the rest of the app doesn't need to
/// know EventKit exists, and detached copies can't crash on stale accessors.
struct ExternalEvent: Identifiable, Hashable {
    let id: String
    let title: String
    let startDate: Date
    let endDate: Date
    let location: String?
    let notes: String?
    let calendarColor: CalendarSwatch

    enum CalendarSwatch: Hashable {
        case blue, mint, lavender, gold, orange

        var background: DesignColor { DesignColor(self) }
    }
}

/// Tiny indirection so `ExternalEvent` doesn't need to import SwiftUI.
struct DesignColor: Hashable {
    let swatch: ExternalEvent.CalendarSwatch
    init(_ swatch: ExternalEvent.CalendarSwatch) { self.swatch = swatch }
}

/// Wraps EventKit so permission handling lives in one place and every other
/// part of the app can treat "no calendar access" as a normal, non-fatal
/// state (per the requirement that permission-denied features degrade
/// gracefully instead of breaking the app).
@Observable
final class CalendarService {
    enum AccessState {
        case notDetermined
        case authorized
        case denied
        case restricted
        case unavailable
    }

    private(set) var accessState: AccessState = .notDetermined
    private(set) var externalEvents: [ExternalEvent] = []

    private let store = EKEventStore()
    private static let swatches: [ExternalEvent.CalendarSwatch] = [.blue, .mint, .lavender, .gold, .orange]

    init() {
        refreshAuthorizationStatus()
    }

    private func refreshAuthorizationStatus() {
        let status = EKEventStore.authorizationStatus(for: .event)
        switch status {
        case .notDetermined: accessState = .notDetermined
        case .authorized, .fullAccess: accessState = .authorized
        case .restricted: accessState = .restricted
        case .denied, .writeOnly: accessState = .denied
        @unknown default: accessState = .unavailable
        }
    }

    /// Requests Calendar access. Safe to call repeatedly; if the user already
    /// answered, this simply reports the existing state instead of re-prompting.
    @MainActor
    func requestAccess() async {
        do {
            let granted: Bool
            if #available(macOS 14.0, *) {
                granted = try await store.requestFullAccessToEvents()
            } else {
                granted = try await store.requestAccess(to: .event)
            }
            accessState = granted ? .authorized : .denied
        } catch {
            accessState = .denied
        }
    }

    /// Loads events in `[start, end)` from every calendar the user has
    /// granted access to. No-ops (leaving `externalEvents` empty) when access
    /// isn't authorized — callers don't need to branch on that themselves.
    func loadEvents(from start: Date, to end: Date) {
        guard accessState == .authorized else {
            externalEvents = []
            return
        }
        let predicate = store.predicateForEvents(withStart: start, end: end, calendars: nil)
        let ekEvents = store.events(matching: predicate)
        externalEvents = ekEvents.enumerated().map { index, event in
            ExternalEvent(
                id: event.eventIdentifier ?? UUID().uuidString,
                title: event.title ?? "Untitled Event",
                startDate: event.startDate,
                endDate: event.endDate,
                location: event.location,
                notes: event.notes,
                calendarColor: Self.swatches[index % Self.swatches.count]
            )
        }
    }
}
