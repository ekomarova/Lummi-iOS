# Changelog

All notable changes to the project will be documented in this file.

## [1.0.0] - 2026-MM-DD
### Fixed
- **Release:** Fixed an issue where the app would fail to compile in the `Release` configuration due to test-only mock data code (`MockDataManager`) leaking into the main target

### Changed
-  **Internal:** Migrated `ThemeManager` from `Combine` (`ObservableObject/@Published`) to the `Observation` framework (`@Observable`), matching the pattern used throughout the rest of the codebase. No user-facing changes
- **Internal:** `JoyEntry.dateKey` is now a computed property derived from `date`, eliminating a redundant stored field and removing the risk of calendar grouping silently breaking if a call site forgot to recalculate the key. No user-facing changes


## [1.0.0rc1] - 2026-09-01
### Added
- **Enhanced Privacy:** Journal entry text is now encrypted when synced via iCloud, ensuring your personal moments remain private and secure
- **Settings:** Clear All Data option in the Settings screen to permanently delete all entries locally and from iCloud
- **iCloud Sync:** You can now seamlessly sync your joy entries across all your Apple devices! This feature is strictly opt-in and can be enabled in Settings
- **iCloud Sync Warning**: If iCloud synchronization is enabled but cannot complete (e.g., your device is not logged into an Apple ID, your iCloud storage is full, or sync is restricted by corporate/parental policies), a helpful warning banner will now appear in the Settings screen
- **iCloud Sync:** Toggling iCloud synchronization in Settings now applies instantly and no requires you to restart the application
- **CI:** Automated GitHub Actions CI workflow that builds, analyzes, and compiles app/tests for the Xcode project on pull requests to master


### Changed
- **Architecture:** Improved ModelContainer initialization
- **Settings:** Redesigned the settings switches with a new segment control for both Appearance and iCloud Sync
- **System Requirements:** Lummi now requires iOS 17.0 or newer to provide the best performance and take full advantage of native SwiftData architecture
- **Insights:** Improved the "Joyful Hours" insights calculation to predictably highlight your most recent active hour when multiple hours have the same number of entries

### Fixed
- **Testing:** Fixed UI tests related to ModelContainer initialization
- **Settings:** Fixed an issue on iPad where the language selection text was too small compared to other menu items. The picker now correctly uses an adaptive font size while maintaining native system behavior
- **Settings UI:** Resolved a visual glitch where the layout would bounce awkwardly when an iCloud sync error banner appeared
- **iCloud Sync:** Fixed an iCloud synchronization issue where the app would get temporarily blocked (rate-limited) by Apple's servers. Changes to entries are now grouped and saved efficiently when you finish typing or close the screen, rather than on every keystroke


## [0.3.0] - 2026-05-11
### Added
- **Joyful Hours Field**: A new analytical metric that identifies the time of day when you capture the most joy
- **Interactive All Moments**: Added a "Tap here" guide to the monthly list card to make it more intuitive

### Changed
- **Architecture**: Migrated analytics logic to a dedicated `InsightsCalculator` for better performance
- **Insights Redesign**: Completely updated the visual language of the Insights screen for a more cohesive and balanced look

### Fixed
- **Smooth Animations**: Fixed a UI glitch where the moments list would fly through the entire Insights screen when expanded

## [0.2.1] - 2026-05-08
### Added
- **New App Icon**: Introduced the App branding
- **Interactive Monthly Archive**: A new expandable section in Insights that lets you revisit all joys from a specific month

### Changed
- **Metric Cards**: Simplified "Joys" and "Day streak" cards for better readability

### Fixed
- **Grid Consistency**: Standardized the width and spacing of all insight cards to ensure a perfect vertical flow


## [0.2.0] - 2026-05-06

### Added
- **Monthly Comparison Insight**: A new analytical block that compares current month performance with the previous one
- **Multi-language Support**: Full manual translation for Russian and German languages using **String Catalogs**
- **In-App Language Picker**: Users can manually switch between English, Russian, and German directly in Settings
- **Dynamic Test IDs**: UI tests now use language-agnostic identifiers, ensuring stability across all supported locales

### Changed
- **Insights Layout**: Improved visual hierarchy by alternating between circular badges and wide rectangular blocks

### Fixed
- **Date Localization**: Fixed a bug where dates didn't update their language
- **Insights View**: Fixed a bug where the month comparison message would overflow its background container on iPad and larger screens


## [0.1.0] - 2026-05-02

### Added
- **Smart Calendar**: Built an expandable calendar with seamless month-to-month navigation and "oldest record" detection
- **Joy Journaling**: Developed full functionality (Create, Read, Update, Delete) for recording and managing daily "Joy Entries"
- **Core Persistence**: Integrated **SwiftData** with support for persistent disk storage and an in-memory mode specifically for automated testing
- **Theming**: Integrated a `ThemeManager` supporting dynamic Light and Dark mode switching with custom color palettes
- **Monthly Insights**: Created a dedicated dashboard that calculates total joys per month and identifies the longest daily streaks
- **Dynamic Messaging**: Implemented a system of adaptive messages for insights based on the number of entries and current streak status
- **UI Automation Suite**: Established a comprehensive suite of **XCUITest** scenarios covering Insights navigation, record management, and settings
