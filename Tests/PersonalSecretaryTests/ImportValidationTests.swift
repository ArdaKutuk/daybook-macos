import SwiftData
import XCTest
@testable import PersonalSecretary

@MainActor
final class ImportValidationTests: XCTestCase {
    private func makeInMemoryContext() throws -> ModelContext {
        let schema = Schema([TaskItem.self, Note.self, Routine.self, RoutineCompletion.self, FocusSession.self, LocalEvent.self, FileShortcut.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [config])
        return container.mainContext
    }

    func testImportingMalformedJSONThrowsInsteadOfCrashing() throws {
        let context = try makeInMemoryContext()
        let garbage = "{ this is not valid json ".data(using: .utf8)!

        XCTAssertThrowsError(try ImportExportService.importJSON(data: garbage, into: context, strategy: .merge)) { error in
            XCTAssertTrue(error is ImportExportError)
        }
    }

    func testImportingEmptyDataThrows() throws {
        let context = try makeInMemoryContext()
        XCTAssertThrowsError(try ImportExportService.importJSON(data: Data(), into: context, strategy: .merge))
    }

    func testExportThenImportRoundTripsTaskData() throws {
        let context = try makeInMemoryContext()
        let task = TaskItem(title: "Roundtrip me", priority: .high, category: .study)
        context.insert(task)
        try context.save()

        let exported = try ImportExportService.exportJSON(context: context)

        let freshContext = try makeInMemoryContext()
        try ImportExportService.importJSON(data: exported, into: freshContext, strategy: .merge)

        let imported = try freshContext.fetch(FetchDescriptor<TaskItem>())
        XCTAssertEqual(imported.count, 1)
        XCTAssertEqual(imported.first?.title, "Roundtrip me")
        XCTAssertEqual(imported.first?.priority, .high)
        XCTAssertEqual(imported.first?.category, .study)
    }

    func testReplaceStrategyClearsExistingDataBeforeImport() throws {
        let context = try makeInMemoryContext()
        context.insert(TaskItem(title: "Old task"))
        try context.save()

        let exported = try ImportExportService.exportJSON(context: try makeInMemoryContext())
        try ImportExportService.importJSON(data: exported, into: context, strategy: .replace)

        let remaining = try context.fetch(FetchDescriptor<TaskItem>())
        XCTAssertTrue(remaining.isEmpty)
    }

    func testResetAllDataRemovesEverything() throws {
        let context = try makeInMemoryContext()
        context.insert(TaskItem(title: "T"))
        context.insert(Note(title: "N"))
        try context.save()

        try ImportExportService.resetAllData(context: context)

        XCTAssertTrue(try context.fetch(FetchDescriptor<TaskItem>()).isEmpty)
        XCTAssertTrue(try context.fetch(FetchDescriptor<Note>()).isEmpty)
    }
}
