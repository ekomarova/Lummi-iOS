//
//  Required Notice: Copyright Evseniia Komarova (https://github.com/ekomarova)
//
//  Licensed under the PolyForm Noncommercial License 1.0.0.
//  See the LICENSE file in the repository root for full terms.
//  <https://polyformproject.org/licenses/noncommercial/1.0.0>
//

import SwiftUI
import Observation

// How the app picks its theme: a fixed light or dark one, or whatever the system is currently using.
enum AppearanceMode: String, CaseIterable {
    case auto
    case light
    case dark
}

// Holds the current theme and persists the appearance choice (light, dark or auto) in UserDefaults.
@Observable
class ThemeManager {
    private static let modeKey = "appearanceMode"
    // Written by versions that only had the light and dark options.
    private static let legacyIsDarkKey = "isDarkMode"

    var mode: AppearanceMode {
        didSet {
            UserDefaults.standard.set(mode.rawValue, forKey: Self.modeKey)
            updateTheme()
        }
    }

    // The system appearance, reported by the root view. It only matters while `mode` is `.auto`.
    var systemColorScheme: ColorScheme = .dark {
        didSet { updateTheme() }
    }

    private(set) var currentTheme: AppTheme

    var isDark: Bool {
        switch mode {
        case .auto: systemColorScheme == .dark
        case .light: false
        case .dark: true
        }
    }

    // `nil` hands control back to the system, so the root view follows it in `.auto`.
    var preferredColorScheme: ColorScheme? {
        switch mode {
        case .auto: nil
        case .light: .light
        case .dark: .dark
        }
    }

    init() {
        let mode = Self.savedMode()
        self.mode = mode
        self.currentTheme = mode == .light ? LightTheme() : DarkTheme()
    }

    private func updateTheme() {
        currentTheme = isDark ? DarkTheme() : LightTheme()
    }

    // Dark stays the default for a fresh install, and an old light/dark choice carries over.
    private static func savedMode() -> AppearanceMode {
        let defaults = UserDefaults.standard
        if let raw = defaults.string(forKey: modeKey), let mode = AppearanceMode(rawValue: raw) {
            return mode
        }
        if let legacyIsDark = defaults.object(forKey: legacyIsDarkKey) as? Bool {
            return legacyIsDark ? .dark : .light
        }
        return .dark
    }
}

// Puts the theme manager into the environment, applies the chosen color scheme and keeps the manager
// informed about the system appearance so the auto mode can follow it.
private struct AppThemeModifier: ViewModifier {
    let themeManager: ThemeManager
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content
            .environment(themeManager)
            .preferredColorScheme(themeManager.preferredColorScheme)
            .onChange(of: colorScheme, initial: true) { _, newValue in
                themeManager.systemColorScheme = newValue
            }
    }
}

extension View {
    func appTheme(_ themeManager: ThemeManager) -> some View {
        modifier(AppThemeModifier(themeManager: themeManager))
    }
}
