import Testing
import SwiftUI
@testable import Lummi

// Serialized to avoid UserDefaults race conditions between tests
@Suite(.serialized)
struct ThemeManagerTests {

    private let key = "isDarkMode"

    init() {
        UserDefaults.standard.removeObject(forKey: "isDarkMode")
    }

    @Test func defaultTheme_isDarkWhenNoPreviousPreference() {
        let manager = ThemeManager()
        #expect(manager.isDark == true)
        #expect(manager.currentTheme is DarkTheme)
    }

    @Test func toggleToLight_switchesCurrentTheme() {
        let manager = ThemeManager()
        manager.isDark = false
        #expect(manager.currentTheme is LightTheme)
    }

    @Test func toggleBackToDark_switchesCurrentTheme() {
        let manager = ThemeManager()
        manager.isDark = false
        manager.isDark = true
        #expect(manager.currentTheme is DarkTheme)
    }

    @Test func toggleIsDark_persistsToUserDefaults() {
        let manager = ThemeManager()
        manager.isDark = false
        let saved = UserDefaults.standard.object(forKey: "isDarkMode") as? Bool
        #expect(saved == false)
    }

    @Test func init_readsPersistedPreferenceFromUserDefaults() {
        UserDefaults.standard.set(false, forKey: "isDarkMode")
        let manager = ThemeManager()
        #expect(manager.isDark == false)
        #expect(manager.currentTheme is LightTheme)
    }
}
