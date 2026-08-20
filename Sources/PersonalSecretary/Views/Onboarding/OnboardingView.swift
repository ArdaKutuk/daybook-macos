import SwiftUI

/// First-launch onboarding. No onboarding mockup existed in the Claude
/// Design prototype (`Daybook.dc.html` only covers the main app), so this
/// screen was composed from the same design tokens/components used
/// everywhere else, to stay visually consistent with the rest of the app.
struct OnboardingView: View {
    var onFinish: () -> Void

    @Environment(CalendarService.self) private var calendarService
    @Environment(NotificationService.self) private var notificationService
    @State private var step = 0

    private struct Page {
        let symbol: String
        let iconBg: Color
        let iconFg: Color
        let title: String
        let subtitle: String
    }

    private let pages: [Page] = [
        Page(symbol: "sun.horizon", iconBg: DT.Color.accentSoftBackground, iconFg: DT.Color.accentDot,
             title: "Welcome to Daybook", subtitle: "Your tasks, calendar, notes, routines, and focus time — all in one calm, local-first place."),
        Page(symbol: "calendar", iconBg: DT.Color.lavenderBackground, iconFg: DT.Color.lavenderDot,
             title: "Stay in sync with Apple Calendar", subtitle: "Daybook can show your Apple Calendar events alongside your tasks. You can always skip this — everything still works without it."),
        Page(symbol: "bell", iconBg: DT.Color.mintBackground, iconFg: DT.Color.mintDot,
             title: "Gentle reminders", subtitle: "Allow notifications so task, routine, and focus reminders can reach you — even if Daybook isn't open."),
        Page(symbol: "bolt", iconBg: DT.Color.goldBackground, iconFg: DT.Color.goldDot,
             title: "Two shortcuts worth remembering", subtitle: "⌥ Space opens Quick Capture from anywhere. ⌘ K searches everything in Daybook.")
    ]

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            let page = pages[step]
            ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(page.iconBg)
                    .frame(width: 72, height: 72)
                Image(systemName: page.symbol)
                    .font(.system(size: 28, weight: .medium))
                    .foregroundStyle(page.iconFg)
            }
            Text(page.title)
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(DT.Color.textPrimary)
                .padding(.top, 22)
            Text(page.subtitle)
                .font(.system(size: 14))
                .foregroundStyle(DT.Color.textSecondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 380)
                .padding(.top, 10)

            HStack(spacing: 6) {
                ForEach(pages.indices, id: \.self) { index in
                    Circle()
                        .fill(index == step ? DT.Color.accentDot : DT.Color.sidebarBorder)
                        .frame(width: 6, height: 6)
                }
            }
            .padding(.top, 28)

            Spacer()

            HStack(spacing: 10) {
                if step == 1 {
                    AppButton(title: "Not Now", style: .text) { advance() }
                    AppButton(title: "Allow Calendar Access", style: .primary) {
                        Task { await calendarService.requestAccess(); advance() }
                    }
                } else if step == 2 {
                    AppButton(title: "Not Now", style: .text) { advance() }
                    AppButton(title: "Allow Notifications", style: .primary) {
                        Task { await notificationService.requestAuthorization(); advance() }
                    }
                } else if step == pages.count - 1 {
                    AppButton(title: "Get Started", style: .primary, action: onFinish)
                } else {
                    AppButton(title: "Continue", style: .primary) { advance() }
                }
            }
            .padding(.bottom, 60)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DT.Color.appBackground)
    }

    private func advance() {
        if step < pages.count - 1 {
            withAnimation(.easeOut(duration: 0.2)) { step += 1 }
        } else {
            onFinish()
        }
    }
}
