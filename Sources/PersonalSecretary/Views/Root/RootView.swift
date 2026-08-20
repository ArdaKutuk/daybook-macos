import SwiftData
import SwiftUI

struct RootView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @Environment(NotificationService.self) private var notificationService

    var body: some View {
        @Bindable var appState = appState

        HStack(spacing: 0) {
            SidebarView()
            VStack(spacing: 0) {
                TopBarView()
                ZStack {
                    DT.Color.appBackground.ignoresSafeArea()
                    ScrollView {
                        content
                            .padding(.top, DT.Spacing.contentTop)
                            .padding(.horizontal, DT.Spacing.contentSide)
                            .padding(.bottom, DT.Spacing.contentBottom)
                    }
                }
            }
        }
        .background(DT.Color.appBackground)
        .frame(minWidth: DT.Size.minWindowWidth, minHeight: DT.Size.minWindowHeight)
        .overlay {
            if appState.showNewTaskSheet {
                ModalOverlay(onTapBackground: { appState.showNewTaskSheet = false }) {
                    NewTaskSheet()
                }
                .transition(.opacity)
            }
        }
        .overlay {
            if appState.showRoutineSheet {
                ModalOverlay(onTapBackground: { appState.showRoutineSheet = false }) {
                    NewRoutineSheet()
                }
                .transition(.opacity)
            }
        }
        .overlay {
            if appState.showQuickCapture {
                ModalOverlay(onTapBackground: { appState.showQuickCapture = false }) {
                    QuickCaptureView(
                        context: modelContext,
                        notificationService: notificationService,
                        onDismiss: { appState.showQuickCapture = false }
                    )
                }
                .transition(.opacity)
            }
        }
        .overlay {
            if appState.showGlobalSearch {
                ModalOverlay(onTapBackground: { appState.showGlobalSearch = false }) {
                    GlobalSearchView(onDismiss: { appState.showGlobalSearch = false })
                }
                .transition(.opacity)
            }
        }
        .animation(.easeOut(duration: 0.15), value: appState.showQuickCapture)
        .animation(.easeOut(duration: 0.15), value: appState.showGlobalSearch)
        .animation(.easeOut(duration: 0.15), value: appState.showNewTaskSheet)
        .animation(.easeOut(duration: 0.15), value: appState.showRoutineSheet)
        .onExitCommand {
            appState.closeAllOverlays()
        }
    }

    @ViewBuilder
    private var content: some View {
        switch appState.selectedSection {
        case .today: DashboardView()
        case .tasks: TasksView()
        case .calendar: CalendarView()
        case .notes: NotesView()
        case .routines: RoutinesView()
        case .focus: FocusView()
        case .files: FilesView()
        case .overview: OverviewView()
        case .settings: SettingsView()
        }
    }
}

/// Full-window dimmed backdrop used by every modal (New Task, New Routine,
/// Quick Capture, Search) matching the prototype's `rgba(20,18,15,0.22)` scrim.
struct ModalOverlay<Content: View>: View {
    var onTapBackground: () -> Void
    @ViewBuilder var content: Content

    var body: some View {
        ZStack {
            DT.Color.modalOverlay
                .ignoresSafeArea()
                .onTapGesture(perform: onTapBackground)
            content
        }
    }
}
