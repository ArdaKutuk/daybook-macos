import SwiftUI

/// Design tokens ported 1:1 from the Claude Design prototype (`Daybook.dc.html`).
/// Every hex value here was read directly out of that file so the native app
/// matches the approved design instead of a reinterpretation of it.
enum DT {

    // MARK: Colors — Background / surfaces

    enum Color {
        static let appBackground = SwiftUI.Color(hex: 0xFAF8F4)
        static let sidebarBackground = SwiftUI.Color(hex: 0xF2EFE9)
        static let sidebarBorder = SwiftUI.Color(hex: 0xE9E4DA)
        static let cardBackground = SwiftUI.Color.white
        static let cardBorder = SwiftUI.Color(hex: 0xE9E4DA)
        static let divider = SwiftUI.Color(hex: 0xF0ECE3)
        static let scrollbarThumb = SwiftUI.Color(hex: 0xE2DDD2)
        static let pillTrackBackground = SwiftUI.Color(hex: 0xF2EFE9)
        static let modalOverlay = SwiftUI.Color.black.opacity(0.22)

        // Text
        static let textPrimary = SwiftUI.Color(hex: 0x2B2A26)
        static let textSecondary = SwiftUI.Color(hex: 0x6B675C)
        static let textTertiary = SwiftUI.Color(hex: 0x98948A)
        static let textPlaceholder = SwiftUI.Color(hex: 0xB4AFA4)

        // Brand / primary accent (blue)
        static let accent = SwiftUI.Color(hex: 0x5C86BE)
        static let accentHover = SwiftUI.Color(hex: 0x4C76AE)
        static let accentSoftBackground = SwiftUI.Color(hex: 0xEAF1FB)
        static let accentSoftBackgroundHover = SwiftUI.Color(hex: 0xDDEAFA)
        static let accentSoftText = SwiftUI.Color(hex: 0x35507A)
        static let accentDot = SwiftUI.Color(hex: 0x7FA6D9)
        static let chartBar = SwiftUI.Color(hex: 0xAFC9E8)

        // Lavender (Calendar / Personal / Files)
        static let lavenderDot = SwiftUI.Color(hex: 0xB79FE3)
        static let lavenderBackground = SwiftUI.Color(hex: 0xF3EEFB)
        static let lavenderText = SwiftUI.Color(hex: 0x5B4A8A)

        // Gold (Notes / Home)
        static let goldDot = SwiftUI.Color(hex: 0xE4CE7A)
        static let goldBackground = SwiftUI.Color(hex: 0xFBF6E2)
        static let goldText = SwiftUI.Color(hex: 0x8A7228)

        // Mint (Routines / Health / success)
        static let mintDot = SwiftUI.Color(hex: 0x8CD1AE)
        static let mintBackground = SwiftUI.Color(hex: 0xEAF7F0)
        static let mintText = SwiftUI.Color(hex: 0x2E6B52)

        // Orange (Tasks / Overview / Study)
        static let orangeDot = SwiftUI.Color(hex: 0xEBAD82)
        static let orangeBackground = SwiftUI.Color(hex: 0xFCEEE4)
        static let orangeText = SwiftUI.Color(hex: 0x9A5A32)

        // Danger / destructive
        static let dangerDot = SwiftUI.Color(hex: 0xE0847A)
        static let dangerText = SwiftUI.Color(hex: 0x9A3D34)
        static let dangerHover = SwiftUI.Color(hex: 0xC97B6E)

        // Neutral (Settings dot)
        static let neutralDot = SwiftUI.Color(hex: 0x98948A)

        static let toggleOn = mintDot
        static let toggleOff = SwiftUI.Color(hex: 0xE2DDD2)
    }

    // MARK: Category / Priority mapping

    enum CategoryStyle {
        static func background(_ category: TaskCategory) -> SwiftUI.Color {
            switch category {
            case .work: return Color.accentSoftBackground
            case .personal: return Color.lavenderBackground
            case .health: return Color.mintBackground
            case .study: return Color.orangeBackground
            case .home: return Color.goldBackground
            }
        }
        static func text(_ category: TaskCategory) -> SwiftUI.Color {
            switch category {
            case .work: return Color.accentSoftText
            case .personal: return Color.lavenderText
            case .health: return Color.mintText
            case .study: return Color.orangeText
            case .home: return Color.goldText
            }
        }
        static func dot(_ category: TaskCategory) -> SwiftUI.Color {
            switch category {
            case .work: return Color.accentDot
            case .personal: return Color.lavenderDot
            case .health: return Color.mintDot
            case .study: return Color.orangeDot
            case .home: return Color.goldDot
            }
        }
    }

    enum PriorityStyle {
        static func dot(_ priority: Priority) -> SwiftUI.Color {
            switch priority {
            case .high: return Color.dangerDot
            case .medium: return Color.goldDot
            case .low: return Color.accentDot
            }
        }
        static func text(_ priority: Priority) -> SwiftUI.Color {
            switch priority {
            case .high: return Color.dangerText
            case .medium: return Color.goldText
            case .low: return Color.accentSoftText
            }
        }
    }

    /// The five rotating icon colors used for routine badges / sidebar dots.
    static let routineIconPalette: [(bg: SwiftUI.Color, fg: SwiftUI.Color)] = [
        (Color.mintBackground, Color.mintText),
        (Color.accentSoftBackground, Color.accentSoftText),
        (Color.lavenderBackground, Color.lavenderText),
        (Color.orangeBackground, Color.orangeText),
        (Color.goldBackground, Color.goldText)
    ]

    // MARK: Sidebar nav dot colors (matches Daybook.dc.html left rail)

    enum NavDot {
        static let today = Color.accentDot
        static let tasks = Color.orangeDot
        static let calendar = Color.lavenderDot
        static let notes = Color.goldDot
        static let routines = Color.mintDot
        static let focus = Color.accentDot
        static let files = Color.lavenderDot
        static let overview = Color.orangeDot
        static let settings = Color.neutralDot
    }

    // MARK: Spacing / Sizing

    enum Spacing {
        static let xxs: CGFloat = 2
        static let xs: CGFloat = 4
        static let sm: CGFloat = 6
        static let smd: CGFloat = 8
        static let md: CGFloat = 10
        static let mdl: CGFloat = 12
        static let lg: CGFloat = 14
        static let lgl: CGFloat = 16
        static let xl: CGFloat = 20
        static let xxl: CGFloat = 24
        static let contentTop: CGFloat = 32
        static let contentSide: CGFloat = 40
        static let contentBottom: CGFloat = 60
    }

    enum Radius {
        static let sm: CGFloat = 7
        static let md: CGFloat = 9
        static let mdl: CGFloat = 10
        static let lg: CGFloat = 11
        static let card: CGFloat = 16
        static let cardSmall: CGFloat = 14
        static let modal: CGFloat = 20
        static let modalSmall: CGFloat = 18
        static let pill: CGFloat = 999
    }

    enum Size {
        static let sidebarWidth: CGFloat = 216
        static let topBarHeight: CGFloat = 52
        static let logoSize: CGFloat = 32
        static let navDot: CGFloat = 7
        static let checkCircle: CGFloat = 20
        static let checkCircleLarge: CGFloat = 26
        static let toggleWidth: CGFloat = 36
        static let toggleHeight: CGFloat = 21
        static let toggleKnob: CGFloat = 17
        static let iconTile: CGFloat = 40
        static let quickActionButton: CGFloat = 30
        static let minWindowWidth: CGFloat = 1100
        static let minWindowHeight: CGFloat = 700
    }

    enum Shadow {
        static let card = (color: SwiftUI.Color.black.opacity(0.04), radius: CGFloat(2), y: CGFloat(1))
        static let popover = (color: SwiftUI.Color.black.opacity(0.12), radius: CGFloat(14), y: CGFloat(8))
        static let modal = (color: SwiftUI.Color.black.opacity(0.15), radius: CGFloat(25), y: CGFloat(20))
    }

    // MARK: Typography — SF Pro (system) stands in for the prototype's Inter,
    // per instructions to use the closest native macOS equivalent.

    enum Font {
        static func heading(_ size: CGFloat) -> SwiftUI.Font { .system(size: size, weight: .semibold, design: .default) }
        static func body(_ size: CGFloat = 13, weight: SwiftUI.Font.Weight = .regular) -> SwiftUI.Font { .system(size: size, weight: weight) }
        static let dashboardGreeting = heading(26)
        static let sectionTitle = heading(22)
        static let cardTitle = SwiftUI.Font.system(size: 15, weight: .semibold)
        static let cardLabel = SwiftUI.Font.system(size: 13, weight: .semibold)
        static let timerDigits = SwiftUI.Font.system(size: 80, weight: .semibold).monospacedDigit()
    }
}

extension SwiftUI.Color {
    init(hex: UInt32, opacity: Double = 1) {
        let r = Double((hex >> 16) & 0xFF) / 255
        let g = Double((hex >> 8) & 0xFF) / 255
        let b = Double(hex & 0xFF) / 255
        self.init(.sRGB, red: r, green: g, blue: b, opacity: opacity)
    }
}
