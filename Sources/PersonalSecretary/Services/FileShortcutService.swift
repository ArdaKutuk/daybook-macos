import AppKit
import Foundation

enum FileShortcutError: LocalizedError {
    case bookmarkCreationFailed
    case bookmarkResolutionFailed
    case fileMissing
    case couldNotOpen

    var errorDescription: String? {
        switch self {
        case .bookmarkCreationFailed: return "Couldn't create a secure reference to that item."
        case .bookmarkResolutionFailed: return "This shortcut is no longer valid."
        case .fileMissing: return "This file or folder appears to have been moved or deleted."
        case .couldNotOpen: return "Couldn't open this item."
        }
    }
}

/// Handles picking files/folders via `NSOpenPanel`, and opening them again
/// later through a security-scoped bookmark. Sandboxed apps can't rely on a
/// plain path string staying valid, so we always round-trip through
/// `URL.bookmarkData(options: .withSecurityScope)`.
enum FileShortcutService {

    /// Presents an open panel letting the user pick files and/or folders.
    /// Runs on the main actor since `NSOpenPanel` must be driven from the
    /// main thread.
    @MainActor
    static func presentPicker(allowsMultiple: Bool = true) -> [URL] {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = allowsMultiple
        panel.resolvesAliases = true
        let response = panel.runModal()
        return response == .OK ? panel.urls : []
    }

    static func makeBookmark(for url: URL) throws -> Data {
        do {
            return try url.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
        } catch {
            throw FileShortcutError.bookmarkCreationFailed
        }
    }

    static func isDirectory(_ url: URL) -> Bool {
        var isDir: ObjCBool = false
        FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir)
        return isDir.boolValue
    }

    /// Resolves a stored bookmark and reveals whether it's stale (the
    /// underlying file moved) so callers can refresh it, without ever
    /// throwing for the common "stale but still resolvable" case.
    struct Resolution {
        let url: URL
        let isStale: Bool
    }

    static func resolve(_ bookmarkData: Data) -> Resolution? {
        var isStale = false
        guard let url = try? URL(
            resolvingBookmarkData: bookmarkData,
            options: .withSecurityScope,
            relativeTo: nil,
            bookmarkDataIsStale: &isStale
        ) else {
            return nil
        }
        return Resolution(url: url, isStale: isStale)
    }

    /// Resolves the bookmark, confirms the target still exists, and opens it
    /// with the default application via `NSWorkspace`. Returns a refreshed
    /// bookmark when the original had gone stale so the caller can persist it.
    @MainActor
    static func open(bookmarkData: Data) async -> Result<Data?, FileShortcutError> {
        guard let resolution = resolve(bookmarkData) else {
            return .failure(.bookmarkResolutionFailed)
        }
        guard resolution.url.startAccessingSecurityScopedResource() else {
            return .failure(.bookmarkResolutionFailed)
        }
        defer { resolution.url.stopAccessingSecurityScopedResource() }

        guard FileManager.default.fileExists(atPath: resolution.url.path) else {
            return .failure(.fileMissing)
        }

        let opened = await NSWorkspace.shared.openAsync(resolution.url)
        guard opened else { return .failure(.couldNotOpen) }

        if resolution.isStale {
            let refreshed = try? makeBookmark(for: resolution.url)
            return .success(refreshed)
        }
        return .success(nil)
    }
}

private extension NSWorkspace {
    func openAsync(_ url: URL) async -> Bool {
        await withCheckedContinuation { continuation in
            self.open(url, configuration: NSWorkspace.OpenConfiguration()) { _, error in
                continuation.resume(returning: error == nil)
            }
        }
    }
}
