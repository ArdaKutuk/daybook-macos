import SwiftData
import SwiftUI

struct DataSettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var showResetConfirmation = false
    @State private var statusMessage: String?
    @State private var isError = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Data").font(.system(size: 18, weight: .semibold)).padding(.bottom, 18)

            HStack(spacing: 10) {
                AppButton(title: "Export JSON", style: .secondary, action: exportJSON)
                AppButton(title: "Export Tasks CSV", style: .secondary, action: exportCSV)
                AppButton(title: "Import", style: .secondary, action: importData)
                AppButton(title: "Reset Data", style: .destructive) { showResetConfirmation = true }
            }

            if let statusMessage {
                Text(statusMessage)
                    .font(.system(size: 12))
                    .foregroundStyle(isError ? DT.Color.dangerText : DT.Color.mintText)
                    .padding(.top, 12)
            }
        }
        .confirmationDialog(
            "Reset all Daybook data?",
            isPresented: $showResetConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete Everything", role: .destructive, action: resetData)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This permanently deletes all tasks, notes, routines, focus history, events, and file shortcuts on this Mac. This can't be undone.")
        }
    }

    private func exportJSON() {
        guard let url = ImportExportService.presentSavePanel(suggestedName: "Daybook Export.json", allowedType: "json") else { return }
        do {
            let data = try ImportExportService.exportJSON(context: modelContext)
            try data.write(to: url)
            report("Exported to \(url.lastPathComponent).", isError: false)
        } catch {
            report(error.localizedDescription, isError: true)
        }
    }

    private func exportCSV() {
        guard let url = ImportExportService.presentSavePanel(suggestedName: "Daybook Tasks.csv", allowedType: "csv") else { return }
        do {
            let data = try ImportExportService.exportTasksCSV(context: modelContext)
            try data.write(to: url)
            report("Exported to \(url.lastPathComponent).", isError: false)
        } catch {
            report(error.localizedDescription, isError: true)
        }
    }

    private func importData() {
        guard let url = ImportExportService.presentOpenPanel() else { return }
        do {
            let data = try Data(contentsOf: url)
            try ImportExportService.importJSON(data: data, into: modelContext, strategy: .merge)
            report("Import complete.", isError: false)
        } catch {
            report(error.localizedDescription, isError: true)
        }
    }

    private func resetData() {
        do {
            try ImportExportService.resetAllData(context: modelContext)
            report("All data has been reset.", isError: false)
        } catch {
            report(error.localizedDescription, isError: true)
        }
    }

    private func report(_ message: String, isError: Bool) {
        self.statusMessage = message
        self.isError = isError
    }
}
