import Testing
import SwiftUI
@testable import Lummi

// Serialized to avoid UserDefaults race conditions between tests
@Suite(.serialized)
struct ThemeManagerTests {

    private let modeKey = "appearanceMode"
    private let legacyKey = "isDarkMode"

    init() {
        UserDefaults.standard.removeObject(forKey: "appearanceMode")
        UserDefaults.standard.removeObject(forKey: "isDarkMode")
    }

    @Test func defaultTheme_isDarkWhenNoPreviousPreference() {
        let manager = ThemeManager()
        #expect(manager.mode == .dark)
        #expect(manager.isDark == true)
        #expect(manager.currentTheme is DarkTheme)
    }

    @Test func switchToLight_switchesCurrentTheme() {
        let manager = ThemeManager()
        manager.mode = .light
        #expect(manager.isDark == false)
        #expect(manager.currentTheme is LightTheme)
    }

    @Test func switchBackToDark_switchesCurrentTheme() {
        let manager = ThemeManager()
        manager.mode = .light
        manager.mode = .dark
        #expect(manager.currentTheme is DarkTheme)
    }

    @Test func modeChange_persistsToUserDefaults() {
        let manager = ThemeManager()
        manager.mode = .light
        #expect(UserDefaults.standard.string(forKey: modeKey) == "light")
        manager.mode = .auto
        #expect(UserDefaults.standard.string(forKey: modeKey) == "auto")
    }

    @Test func init_readsPersistedModeFromUserDefaults() {
        UserDefaults.standard.set("light", forKey: modeKey)
        let manager = ThemeManager()
        #expect(manager.mode == .light)
        #expect(manager.currentTheme is LightTheme)
    }

    @Test func init_ignoresUnknownPersistedMode() {
        UserDefaults.standard.set("sepia", forKey: modeKey)
        let manager = ThemeManager()
        #expect(manager.mode == .dark)
    }

    // MARK: - Migration from the old light/dark flag

    @Test func init_migratesLegacyLightChoice() {
        UserDefaults.standard.set(false, forKey: legacyKey)
        let manager = ThemeManager()
        #expect(manager.mode == .light)
        #expect(manager.currentTheme is LightTheme)
    }

    @Test func init_migratesLegacyDarkChoice() {
        UserDefaults.standard.set(true, forKey: legacyKey)
        let manager = ThemeManager()
        #expect(manager.mode == .dark)
    }

    @Test func init_prefersNewModeOverLegacyFlag() {
        UserDefaults.standard.set(false, forKey: legacyKey)
        UserDefaults.standard.set("auto", forKey: modeKey)
        let manager = ThemeManager()
        #expect(manager.mode == .auto)
    }

    // MARK: - Auto mode

    @Test func auto_followsLightSystem() {
        let manager = ThemeManager()
        manager.mode = .auto
        manager.systemColorScheme = .light
        #expect(manager.isDark == false)
        #expect(manager.currentTheme is LightTheme)
    }

    @Test func auto_followsDarkSystem() {
        let manager = ThemeManager()
        manager.systemColorScheme = .light
        manager.mode = .auto
        manager.systemColorScheme = .dark
        #expect(manager.isDark == true)
        #expect(manager.currentTheme is DarkTheme)
    }

    @Test func auto_updatesWhenSystemChanges() {
        let manager = ThemeManager()
        manager.mode = .auto
        manager.systemColorScheme = .light
        manager.systemColorScheme = .dark
        #expect(manager.currentTheme is DarkTheme)
        manager.systemColorScheme = .light
        #expect(manager.currentTheme is LightTheme)
    }

    @Test func fixedModes_ignoreSystemChanges() {
        let manager = ThemeManager()
        manager.mode = .dark
        manager.systemColorScheme = .light
        #expect(manager.currentTheme is DarkTheme)
        manager.mode = .light
        manager.systemColorScheme = .dark
        #expect(manager.currentTheme is LightTheme)
    }

    @Test func preferredColorScheme_isNilOnlyForAuto() {
        let manager = ThemeManager()
        manager.mode = .auto
        #expect(manager.preferredColorScheme == nil)
        manager.mode = .light
        #expect(manager.preferredColorScheme == .light)
        manager.mode = .dark
        #expect(manager.preferredColorScheme == .dark)
    }
}
