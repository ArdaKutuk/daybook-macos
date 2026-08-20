import AppKit
import Foundation
import SwiftData

enum ImportExportError: LocalizedError {
    case encodingFailed
    case decodingFailed(String)
    case unsupportedVersion
    case noFileChosen

    var errorDescription: String? {
        switch self {
        case .encodingFailed: return "Couldn't prepare your data for export."
        case .decodingFailed(let reason): return "That file couldn't be read as Daybook data (\(reason))."
        case .unsupportedVersion: return "This export was made with a newer, incompatible version of Daybook."
        case .noFileChosen: return "No file was chosen."
        }
    }
}

// MARK: - Codable DTOs (SwiftData models hold relationships that don't
// round-trip cleanly through Codable, so we mirror them with plain structs).

private struct TaskDTO: Codable {
    var id: UUID
    var title: String
    var taskDescription: String
    var dueDate: Date?
    var dueTime: Date?
    var priority: String
    var category: String
    var status: String
    var createdAt: Date
    var updatedAt: Date
    var completedAt: Date?
    var reminderEnabled: Bool
    var reminderDate: Date?
    var recurrenceRule: String

    init(_ t: TaskItem) {
        id = t.id; title = t.title; taskDescription = t.taskDescription
        dueDate = t.dueDate; dueTime = t.dueTime
        priority = t.priorityRaw; category = t.categoryRaw; status = t.statusRaw
        createdAt = t.createdAt; updatedAt = t.updatedAt; completedAt = t.completedAt
        reminderEnabled = t.reminderEnabled; reminderDate = t.reminderDate
        recurrenceRule = t.recurrenceRuleRaw
    }

    func makeModel() -> TaskItem {
        let task = TaskItem(
            id: id, title: title, taskDescription: taskDescription,
            dueDate: dueDate, dueTime: dueTime,
            priority: Priority(rawValue: priority) ?? .medium,
            category: TaskCategory(rawValue: category) ?? .work,
            status: TaskStatus(rawValue: status) ?? .pending,
            reminderEnabled: reminderEnabled, reminderDate: reminderDate,
            recurrenceRule: RecurrenceRule(rawValue: recurrenceRule) ?? .none
        )
        task.createdAt = createdAt; task.updatedAt = updatedAt; task.completedAt = completedAt
        return task
    }
}

private struct NoteDTO: Codable {
    var id: UUID; var title: String; var content: String
    var category: String; var pinned: Bool; var createdAt: Date; var updatedAt: Date

    init(_ n: Note) {
        id = n.id; title = n.title; content = n.content
        category = n.categoryRaw; pinned = n.pinned; createdAt = n.createdAt; updatedAt = n.updatedAt
    }

    func makeModel() -> Note {
        let note = Note(id: id, title: title, content: content, category: TaskCategory(rawValue: category) ?? .personal, pinned: pinned)
        note.createdAt = createdAt; note.updatedAt = updatedAt
        return note
    }
}

private struct RoutineDTO: Codable {
    var id: UUID; var name: String; var routineDescription: String; var symbol: String
    var frequency: String; var selectedWeekdays: [Int]; var preferredTime: Date?
    var reminderEnabled: Bool; var currentStreak: Int; var bestStreak: Int
    var createdAt: Date; var paletteIndex: Int
    var completionDates: [Date]

    init(_ r: Routine) {
        id = r.id; name = r.name; routineDescription = r.routineDescription; symbol = r.symbol
        frequency = r.frequencyRaw; selectedWeekdays = r.selectedWeekdaysRaw; preferredTime = r.preferredTime
        reminderEnabled = r.reminderEnabled; currentStreak = r.currentStreak; bestStreak = r.bestStreak
        createdAt = r.createdAt; paletteIndex = r.paletteIndex
        completionDates = (r.completions ?? []).map(\.date)
    }

    func makeModel() -> (Routine, [RoutineCompletion]) {
        let routine = Routine(
            id: id, name: name, routineDescription: routineDescription, symbol: symbol,
            frequency: RoutineFrequency(rawValue: frequency) ?? .daily,
            selectedWeekdays: selectedWeekdays.compactMap(Weekday.init(rawValue:)),
            preferredTime: preferredTime, reminderEnabled: reminderEnabled, paletteIndex: paletteIndex
        )
        routine.currentStreak = currentStreak; routine.bestStreak = bestStreak; routine.createdAt = createdAt
        let completions = completionDates.map { RoutineCompletion(date: $0, routine: routine) }
        return (routine, completions)
    }
}

private struct FocusSessionDTO: Codable {
    var id: UUID; var startDate: Date; var endDate: Date; var duration: TimeInterval
    var completed: Bool; var taskLabel: String

    init(_ f: FocusSession) {
        id = f.id; startDate = f.startDate; endDate = f.endDate
        duration = f.duration; completed = f.completed; taskLabel = f.taskLabel
    }

    func makeModel() -> FocusSession {
        FocusSession(id: id, startDate: startDate, endDate: endDate, duration: duration, completed: completed, relatedTask: nil, taskLabel: taskLabel)
    }
}

private struct LocalEventDTO: Codable {
    var id: UUID; var title: String; var eventDescription: String
    var startDate: Date; var endDate: Date; var location: String; var reminder: String

    init(_ e: LocalEvent) {
        id = e.id; title = e.title; eventDescription = e.eventDescription
        startDate = e.startDate; endDate = e.endDate; location = e.location; reminder = e.reminderRaw
    }

    func makeModel() -> LocalEvent {
        LocalEvent(id: id, title: title, eventDescription: eventDescription, startDate: startDate, endDate: endDate, location: location, reminder: ReminderOffset(rawValue: reminder) ?? .none)
    }
}

private struct ExportBundle: Codable {
    var formatVersion: Int
    var exportedAt: Date
    var tasks: [TaskDTO]
    var notes: [NoteDTO]
    var routines: [RoutineDTO]
    var focusSessions: [FocusSessionDTO]
    var events: [LocalEventDTO]
}

enum ImportStrategy {
    /// Deletes all existing data before importing.
    case replace
    /// Keeps existing data and adds imported records alongside it.
    case merge
}

@MainActor
enum ImportExportService {
    private static let currentFormatVersion = 1

    // MARK: Export

    static func exportJSON(context: ModelContext) throws -> Data {
        let bundle = try makeBundle(context: context)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        do {
            return try encoder.encode(bundle)
        } catch {
            throw ImportExportError.encodingFailed
        }
    }

    static func exportTasksCSV(context: ModelContext) throws -> Data {
        let tasks = try context.fetch(FetchDescriptor<TaskItem>(sortBy: [SortDescriptor(\.createdAt)]))
        var rows = ["Title,Description,Due Date,Priority,Category,Status,Completed At"]
        let formatter = ISO8601DateFormatter()
        for task in tasks {
            let fields: [String] = [
                csvEscape(task.title),
                csvEscape(task.taskDescription),
                task.dueDate.map { formatter.string(from: $0) } ?? "",
                task.priority.rawValue,
                task.category.rawValue,
                task.status.rawValue,
                task.completedAt.map { formatter.string(from: $0) } ?? ""
            ]
            rows.append(fields.joined(separator: ","))
        }
        guard let data = rows.joined(separator: "\n").data(using: .utf8) else {
            throw ImportExportError.encodingFailed
        }
        return data
    }

    private static func csvEscape(_ field: String) -> String {
        guard field.contains(",") || field.contains("\"") || field.contains("\n") else { return field }
        return "\"\(field.replacingOccurrences(of: "\"", with: "\"\""))\""
    }

    private static func makeBundle(context: ModelContext) throws -> ExportBundle {
        let tasks = try context.fetch(FetchDescriptor<TaskItem>())
        let notes = try context.fetch(FetchDescriptor<Note>())
        let routines = try context.fetch(FetchDescriptor<Routine>())
        let sessions = try context.fetch(FetchDescriptor<FocusSession>())
        let events = try context.fetch(FetchDescriptor<LocalEvent>())
        return ExportBundle(
            formatVersion: currentFormatVersion,
            exportedAt: .now,
            tasks: tasks.map(TaskDTO.init),
            notes: notes.map(NoteDTO.init),
            routines: routines.map(RoutineDTO.init),
            focusSessions: sessions.map(FocusSessionDTO.init),
            events: events.map(LocalEventDTO.init)
        )
    }

    // MARK: Import

    static func importJSON(data: Data, into context: ModelContext, strategy: ImportStrategy) throws {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let bundle: ExportBundle
        do {
            bundle = try decoder.decode(ExportBundle.self, from: data)
        } catch {
            throw ImportExportError.decodingFailed(shortReason(for: error))
        }
        guard bundle.formatVersion <= currentFormatVersion else {
            throw ImportExportError.unsupportedVersion
        }

        if strategy == .replace {
            try resetAllData(context: context)
        }

        for dto in bundle.tasks { context.insert(dto.makeModel()) }
        for dto in bundle.notes { context.insert(dto.makeModel()) }
        for dto in bundle.routines {
            let (routine, completions) = dto.makeModel()
            context.insert(routine)
            completions.forEach { context.insert($0) }
        }
        for dto in bundle.focusSessions { context.insert(dto.makeModel()) }
        for dto in bundle.events { context.insert(dto.makeModel()) }

        try context.save()
    }

    private static func shortReason(for error: Error) -> String {
        if let decodingError = error as? DecodingError {
            switch decodingError {
            case .keyNotFound(let key, _): return "missing field \"\(key.stringValue)\""
            case .typeMismatch(_, let ctx): return ctx.debugDescription
            case .valueNotFound(_, let ctx): return ctx.debugDescription
            case .dataCorrupted: return "corrupted data"
            @unknown default: return "unknown format error"
            }
        }
        return error.localizedDescription
    }

    // MARK: Reset

    static func resetAllData(context: ModelContext) throws {
        try context.delete(model: TaskItem.self)
        try context.delete(model: Note.self)
        try context.delete(model: RoutineCompletion.self)
        try context.delete(model: Routine.self)
        try context.delete(model: FocusSession.self)
        try context.delete(model: LocalEvent.self)
        try context.delete(model: FileShortcut.self)
        try context.save()
    }

    // MARK: Panels

    static func presentSavePanel(suggestedName: String, allowedType: String) -> URL? {
        let panel = NSSavePanel()
        panel.nameFieldStringValue = suggestedName
        panel.canCreateDirectories = true
        return panel.runModal() == .OK ? panel.url : nil
    }

    static func presentOpenPanel() -> URL? {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        return panel.runModal() == .OK ? panel.url : nil
    }
}
