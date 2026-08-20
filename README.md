# Daybook — Personal Secretary for macOS

A native, local-first personal secretary app for macOS: tasks, calendar, notes,
routines, focus timer, file shortcuts, and daily/weekly overview — built with
Swift, SwiftUI, and SwiftData. The UI is a 1:1 native implementation of the
Claude Design prototype (`Daybook.dc.html`) in the parent folder.

## Features

- **Today Dashboard** — greeting, today's tasks, next event, daily progress, routine progress, focus summary, quick note, tomorrow preview
- **Tasks** — full CRUD, Today/Upcoming/All/Completed filters, priority & category filters, search, recurring tasks (daily/weekly)
- **Calendar** — Month/Week/Day views, local events, Apple Calendar (EventKit) read integration, task due dates on the grid
- **Notes** — split-pane list + editor, pin, category, debounced autosave
- **Routines** — daily/selected-days/weekly scheduling, streak tracking (current + best), completion history
- **Focus** — Pomodoro-style timer (25/5, 50/10, custom), task linking, session history, daily totals
- **Files** — file/folder shortcuts via security-scoped bookmarks, stale-bookmark handling
- **Overview** — 7/30-day analytics (tasks completed, completion rate, focus time, routine completion, most productive day) with a Swift Charts bar chart
- **Settings** — General, Appearance, Focus, Notifications, Shortcuts, Data (export/import/reset), Launch at Login
- **Menu Bar** — MenuBarExtra popover with today's remaining tasks, next event, and quick actions
- **Quick Capture** — ⌥ Space global hotkey opens a floating capture panel (Task or Note) from anywhere
- **Global Search** — ⌘ K searches tasks, notes, events, and routines with full keyboard navigation
- **Onboarding** — first-launch walkthrough with inline permission requests

## Stack

- Swift 5.10, SwiftUI, SwiftData
- EventKit (Calendar), UserNotifications (reminders), ServiceManagement (Launch at Login)
- Carbon Event Manager for the global ⌥ Space hotkey (no Accessibility permission required)
- Swift Charts for Overview
- AppKit where SwiftUI has no native equivalent (`NSOpenPanel`/`NSSavePanel`, security-scoped bookmarks, the floating Quick Capture `NSPanel`)

## Requirements

- macOS 14.0 or later (Sonoma+), Apple Silicon
- Xcode 15+ to build the `.xcodeproj` (generated via [XcodeGen](https://github.com/yonaskolb/XcodeGen))

## How to Run

This repo ships **source only** plus a generator config — the `.xcodeproj` is
generated, not committed, so it always reflects the current `project.yml`.

```bash
brew install xcodegen   # if you don't already have it
cd PersonalSecretary
xcodegen generate
open PersonalSecretary.xcodeproj
```

Then press ⌘R in Xcode. First launch shows onboarding; subsequent launches
open straight to your configured Start Page (default: Today).

### Building a distributable app + .dmg

```bash
./scripts/build-app.sh
```

This regenerates the project, builds a universal (arm64 + x86_64) Release
binary, verifies the bundle (executable name, `Info.plist`, architecture,
signature) and writes `dist/Daybook-1.0.dmg`.

With no signing identity set it signs ad-hoc, which runs locally but shows a
Gatekeeper prompt on other Macs. For a distributable build, pass your own
credentials through the environment — they are never stored in the repo:

```bash
DEVELOPMENT_TEAM=XXXXXXXXXX CODE_SIGN_IDENTITY="Developer ID Application" ./scripts/build-app.sh
```

### Command-line build/test (no Xcode required)

A `Package.swift` is included purely as a fast compile/test harness for
environments without full Xcode (e.g. CI, or Command Line Tools only):

```bash
swift build
swift test
```

Both the SPM package and the generated Xcode project point at the same
`Sources/PersonalSecretary` tree, so there's a single source of truth.

## Architecture

```
Sources/PersonalSecretary/
  App/            App entry point, AppDelegate, AppState, ServiceContainer, Commands
  Models/         SwiftData @Model types (TaskItem, Note, Routine, RoutineCompletion,
                   FocusSession, LocalEvent, FileShortcut) + shared enums
  Views/          One folder per feature (Dashboard, Tasks, Calendar, Notes, Routines,
                   Focus, Files, Overview, Settings, QuickCapture, Search, MenuBar,
                   Onboarding, Root)
  Components/     Reusable design-system pieces (AppButton, SidebarItem, TaskRow, ...)
  ViewModels/     Pure, testable business logic (filtering, streaks, stats) —
                   Views own live `@Query` data; ViewModels turn it into display data
  Services/       External-system integrations (EventKit, UserNotifications,
                   ServiceManagement, Carbon hotkey, file bookmarks, import/export)
  Repositories/   Thin SwiftData read/write layer per model
  Utilities/      Design tokens, streak/recurrence math, settings keys
  Extensions/     Date/Color helpers
  Resources/      Info.plist, entitlements, Assets.xcassets (app icon)
Tests/PersonalSecretaryTests/   XCTest coverage for the pure logic above
```

`TaskItem` (not `Task`) is used for the task model to avoid colliding with
Swift's built-in `Task` concurrency type.

## Permissions

- **Calendar** — requested when you open the Calendar tab or during onboarding; if denied, Daybook keeps working with its own events/tasks only.
- **Notifications** — requested the first time you enable a notification toggle in Settings; if denied, reminders simply don't fire (no crashes, no blocking).
- **File access** — sandboxed with `com.apple.security.files.user-selected.read-write`; file/folder shortcuts are stored as security-scoped bookmarks, not raw paths, and are re-validated (with a clear "file not found" state) every time you open one.

All three degrade gracefully — none of them are required for the app to be useful.

## Keyboard Shortcuts

| Shortcut | Action |
|---|---|
| ⌘N | New Task |
| ⌘⇧N | New Note |
| ⌘K | Global Search |
| ⌥ Space | Quick Capture (works even when Daybook isn't frontmost) |
| ⌘, | Settings |
| ⌘1 / ⌘2 / ⌘3 | Today / Tasks / Calendar |

The Quick Capture shortcut is registered through `GlobalHotkeyService`, built
so it can be made user-configurable later without touching the rest of the app.

## Data & Privacy

Daybook is **local-first**: everything lives in a SwiftData store on your Mac.
There is no account, no login, no cloud sync, and no analytics. Export/Import
(Settings > Data) writes/reads plain JSON (and a CSV export for tasks) via
`NSSavePanel`/`NSOpenPanel` — nothing leaves your Mac unless you choose to
move that file yourself. "Reset Data" is a destructive, confirmed action that
clears the local store.

## Known Limitations

- Drag-and-drop reordering of file shortcuts was left out (called out as
  optional in the spec) to prioritize the full feature set.
- Apple Calendar integration is read-only (by design — Daybook doesn't write
  events back into your Apple Calendar).
- The app ships without a committed `.xcodeproj`; run `xcodegen generate`
  once after cloning (see **How to Run**).
