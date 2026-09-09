# Changelog

All notable changes to the project will be documented in this file.

## [1.0.0] - 2026-MM-DD
### Added
- **Testing:** Added unit tests using the Swift Testing framework, covering all testable business logic: `InsightsCalculator` (filter, streak, golden hours), `DateExtension` (formatting, month navigation, boundary checks), `ThemeManager` (persistence, theme switching), and `JoyEntry.dateKey`

### Fixed
- **iPad:** Background content is now blurred when the "new record" sheet is open, consistent with other modal overlays in the app
- **iOS 17 / iPhone SE:** Fixed a UI freeze that occurred on iOS 17.0 when navigating to Calendar or Insights after switching language in Settings. `WeekdayHeaderView` was evaluating `weekdayLabels` twice per `body` call — once for `ForEach` indices and once per `Text` — creating 8 `DateFormatter` instances per render frame; replaced with a single `Calendar.locale` lookup stored in a local variable
- **iOS 17 / iPhone SE:** Fixed the same freeze root cause in `InsightsCalculator.calculateGoldenHours`: `setLocalizedDateFormatFromTemplate("jmm")` was called on every render, acquiring an ICU lock each time; replaced with `Date.FormatStyle`

## [1.0.0rc3] - 2026-09-04
### Added
- **Testing:** Added `SaveFailureUITests` — a new UI test suite covering save, edit, and delete failure paths. A new `-UI_TESTING_SIMULATE_SAVE_FAILURE` launch argument triggers a simulated save error so the failure UI can be exercised without reproducing real-world conditions (full disk, corrupted store, etc.)

### Changed
- **Internal:** Replaced a fragile `DispatchQueue.main.asyncAfter(+0.1s)` timer used to sequence keyboard focus and scroll-to-cell when entering edit mode in `SelectedDayDetailView` with a `.onChange(of: isEditing)` modifier, which fires after SwiftUI has committed the state change. No user-facing changes
- **Internal:** Eliminated per-call `DateFormatter` allocations across the codebase. `Date.stringKey` now uses a single static formatter (fixed `en_US_POSIX` locale). A new `Date.format(_:locale:)` helper caches one `DateFormatter` per format-string/locale pair, so `HeaderView`, `InsightsView` month label, and `MonthlyMomentCell` all reuse already-created instances on every render. No user-facing changes
- **Internal:** Merged `InsightGlowCard` and `RhythmGlowCard` into a single `GlowCard` component parameterised by `height`, `valueFontSize`, and `valuePadding`. No user-facing changes

### Fixed
- **Data Safety:** Fixed a silent data-loss risk where `try? modelContext.save()` in three places (`RecordInput` on new-entry save, and `deleteNote` / `saveAndDismiss` in `SelectedDayDetailView`) would silently discard save failures. The app now rolls back the context, keeps the UI open, and shows a themed error alert consistent with the existing modal style. Users are never left believing an entry was saved when it wasn't
- **Localisation:** Added missing Russian and German translations for three new error-alert strings
- **Localisation:** Fixed a bug where the `"Sync issue: %@"` banner message in `Settings` was missing the `%@` placeholder in all three language translations, causing the actual error description to be silently dropped from the UI


## [1.0.0rc2] - 2026-09-02
### Added
- **Record Input:** Joy entry text is now capped at 280 characters. A live character counter below the text field shows how many characters you've used and highlights as you approach the limit

### Changed
-  **Internal:** Migrated `ThemeManager` from `Combine` (`ObservableObject/@Published`) to the `Observation` framework (`@Observable`), matching the pattern used throughout the rest of the codebase. No user-facing changes
- **Internal:** `JoyEntry.dateKey` is now a computed property derived from `date`, eliminating a redundant stored field and removing the risk of calendar grouping silently breaking if a call site forgot to recalculate the key. No user-facing changes
- **Internal:** Aligned `IPHONEOS_DEPLOYMENT_TARGET` across all targets — `LummiTests` and `LummiUITests` were inheriting the project-level iOS 26.4 default instead of the app's iOS 17 minimum, preventing tests from running on iOS 17–25 simulators
- **Internal:** Pinned `SWIFT_VERSION = 5.0` at the project level; updated README requirements to reflect iOS 17.6+ and Swift 5.0+
- **Settings:** The `Clear All Data` confirmation dialog now blurs the background content while it is visible, consistent with other modal overlays in the app

### Fixed
- **Release:** Fixed an issue where the app would fail to compile in the `Release` configuration due to test-only mock data code (`MockDataManager`) leaking into the main target
- **Day Detail:** Fixed a bug where editing or deleting a joy entry could silently target the wrong record if two entries shared the same date (e.g. after a CloudKit merge). The active selection is now tracked by stable `PersistentIdentifier` instead of a positional array index
- **iCloud Sync:** Fixed a crash (`fatalError`) that could occur when toggling iCloud sync if `ModelContainer` failed to reinitialize at runtime (e.g. due to a corrupted store or filesystem issue). The app now reverts the toggle and shows an error dialog instead of terminating
- **iCloud Sync:** Fixed a visual glitch where the iCloud error banner would briefly flash when a container initialization failure caused the sync toggle to revert
- **iCloud Sync:** Fixed a bug where the "iCloud storage is full" warning banner could remain visible in `Settings` for the entire session after the user freed up iCloud storage. The banner now disappears automatically once CloudKit successfully resumes syncing


## [1.0.0rc1] - 2026-09-01
### Added
- **Enhanced Privacy:** Journal entry text is now encrypted when synced via iCloud, ensuring your personal moments remain private and secure
- **Settings:** `Clear All Data` option in the `Settings` screen to permanently delete all entries locally and from iCloud
- **iCloud Sync:** You can now seamlessly sync your joy entries across all your Apple devices! This feature is strictly opt-in and can be enabled in `Settings`
- **iCloud Sync Warning**: If iCloud synchronization is enabled but cannot complete (e.g., your device is not logged into an Apple ID, your iCloud storage is full, or sync is restricted by corporate/parental policies), a helpful warning banner will now appear in the `Settings` screen
- **iCloud Sync:** Toggling iCloud synchronization in `Settings` now applies instantly and no requires you to restart the application
- **CI:** Automated GitHub Actions CI workflow that builds, analyzes, and compiles app/tests for the Xcode project on pull requests to master


### Changed
- **Architecture:** Improved `ModelContainer` initialization
- **Settings:** Redesigned the settings switches with a new segment control for both Appearance and iCloud Sync
- **System Requirements:** Lummi now requires iOS 17.0 or newer to provide the best performance and take full advantage of native `SwiftData` architecture
- **Insights:** Improved the `Joyful Hours` insights calculation to predictably highlight your most recent active hour when multiple hours have the same number of entries

### Fixed
- **Testing:** Fixed UI tests related to `ModelContainer` initialization
- **Settings:** Fixed an issue on iPad where the language selection text was too small compared to other menu items. The picker now correctly uses an adaptive font size while maintaining native system behavior
- **Settings UI:** Resolved a visual glitch where the layout would bounce awkwardly when an iCloud sync error banner appeared
- **iCloud Sync:** Fixed an iCloud synchronization issue where the app would get temporarily blocked (rate-limited) by Apple's servers. Changes to entries are now grouped and saved efficiently when you finish typing or close the screen, rather than on every keystroke


## [0.3.0] - 2026-05-11
### Added
- **Joyful Hours Field**: A new analytical metric that identifies the time of day when you capture the most joy
- **Interactive All Moments**: Added a `Tap here` guide to the monthly list card to make it more intuitive

### Changed
- **Architecture**: Migrated analytics logic to a dedicated `InsightsCalculator` for better performance
- **Insights Redesign**: Completely updated the visual language of the `Insights` screen for a more cohesive and balanced look

### Fixed
- **Smooth Animations**: Fixed a UI glitch where the moments list would fly through the entire Insights screen when expanded

## [0.2.1] - 2026-05-08
### Added
- **New App Icon**: Introduced the App branding
- **Interactive Monthly Archive**: A new expandable section in `Insights` that lets you revisit all joys from a specific month

### Changed
- **Metric Cards**: Simplified `Joys` and `Day streak` cards for better readability

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
- **Joy Journaling**: Developed full functionality (Create, Read, Update, Delete) for recording and managing daily `Joy Entries`
- **Core Persistence**: Integrated **SwiftData** with support for persistent disk storage and an in-memory mode specifically for automated testing
- **Theming**: Integrated a `ThemeManager` supporting dynamic Light and Dark mode switching with custom color palettes
- **Monthly Insights**: Created a dedicated dashboard that calculates total joys per month and identifies the longest daily streaks
- **Dynamic Messaging**: Implemented a system of adaptive messages for insights based on the number of entries and current streak status
- **UI Automation Suite**: Established a comprehensive suite of **XCUITest** scenarios covering Insights navigation, record management, and settings
