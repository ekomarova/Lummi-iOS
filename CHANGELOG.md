# Changelog

All notable changes to the project will be documented in this file.
## [1.2.0] - 2026-MM-DD
### Added
- Added the new `Trends` page in `Insights` with a "Month"/"All Time" summary and bar charts [#36](https://github.com/ekomarova/Lummi-iOS/pull/36)
- Added manual performance tests for `Insights`, `All Joys`, `Trends` (`RUN_PERFORMANCE_TESTS=1`), and a read-only `performance-profile` skill [#40](https://github.com/ekomarova/Lummi-iOS/pull/40)
- Added `#Preview` for every view and component [#27](https://github.com/ekomarova/Lummi-iOS/pull/27)

### Changed
- Changed the minimum deployment target from iOS 17.6 to iOS 18.0
- Updated `All Joys` page with a "Month"/"All Time" summary [#41](https://github.com/ekomarova/Lummi-iOS/pull/41)
- Showed the date in `All Joys` only on the latest joy of each day; the other joys of that day appear without it [#42](https://github.com/ekomarova/Lummi-iOS/pull/42)
- Adapted `Trends` to iPad [#43](https://github.com/ekomarova/Lummi-iOS/pull/43)

### Fixed
- Stopped the app from crashing on launch when its storage cannot be opened [#44](https://github.com/ekomarova/Lummi-iOS/pull/44)
- Stopped `Settings` from contacting iCloud while sync is turned off [#45](https://github.com/ekomarova/Lummi-iOS/pull/45)
- Restored the entry's original text when saving an edit fails [#27](https://github.com/ekomarova/Lummi-iOS/pull/27)
- Fixed `Joyful Hours` to use a sliding three-hour window (wrapping past midnight) with the most entries; ties go to the window with the most recent entry [#18](https://github.com/ekomarova/Lummi-iOS/pull/18)

### Performance
- Fetched only the entries `Calendar`/`Day`/`Insights` show instead of loading every entry. With 5,000 entries: calendar ~47% fewer CPU instructions and 23% less memory, day switching ~27% fewer instructions and 31% less memory [#32](https://github.com/ekomarova/Lummi-iOS/pull/32)
- Fetched only the month/year on screen and computes cards/charts in one pass in `All Joys` and `Trends` [#40](https://github.com/ekomarova/Lummi-iOS/pull/40), [#42](https://github.com/ekomarova/Lummi-iOS/pull/42)

### Refactored
- Moved Calendar math to `CalendarMonthLayout` [#27](https://github.com/ekomarova/Lummi-iOS/pull/27)
- Replaced duplicated buttons with `NavigationIconButton`, `RecordActionButton`, `ScreenHeader` and `CapsuleRow` [#28](https://github.com/ekomarova/Lummi-iOS/pull/28)
- Extracted `GlowCard` builders and `NoteBubble`, and added `Date.monthYearTitle(locale:)` and `Calendar.lummiCalendar(locale:)` [#29](https://github.com/ekomarova/Lummi-iOS/pull/29)
- Replaced duplicated card styling with the `cardBackground` modifier and `CardOpacity` constants [#30](https://github.com/ekomarova/Lummi-iOS/pull/30)
- Replaced the `ContentView` navigation booleans with `NavigationState` and a `Screen` enum [#31](https://github.com/ekomarova/Lummi-iOS/pull/31)
- Replaced raw animation and color literals with `Animation.lummiSpring` and `AccentColors` [#37](https://github.com/ekomarova/Lummi-iOS/pull/37)
- Added `GlowCard.joys`/`.streak`/`.joyfulHours` and `DisclosureRow`, and replaced three copies of the month-start logic with `Calendar.monthStart(for:)` [#37](https://github.com/ekomarova/Lummi-iOS/pull/37)
- Refactored the `Insights` screen [#39](https://github.com/ekomarova/Lummi-iOS/pull/39)
- Extracted a reusable section title for `Insights` and `Settings` and removed unused helpers [#39](https://github.com/ekomarova/Lummi-iOS/pull/39)

## [1.1.0] - 2026-09-19
### Added
- Redesigned the app with Liquid Glass with a fallback on iOS 17.6-18 [#12](https://github.com/ekomarova/Lummi-iOS/pull/12)
- Merged the bottom navigation into a single toolbar with tab labels [#12](https://github.com/ekomarova/Lummi-iOS/pull/12)
- Added `Highlights`/`Recall` sections to `Insights` [#12](https://github.com/ekomarova/Lummi-iOS/pull/12)
- Showed `Joys`, `Day Streak` and `Joyful Hours` as one square row on iPad [#12](https://github.com/ekomarova/Lummi-iOS/pull/12)
- Added selection haptic feedback to the record button [#12](https://github.com/ekomarova/Lummi-iOS/pull/12)

### Changed
- Replaced the `New Joy` with a full in-flow page, matching `All joys` and `Language` [#12](https://github.com/ekomarova/Lummi-iOS/pull/12)
- Replaced custom alert overlays with native `.alert()` dialogs [#12](https://github.com/ekomarova/Lummi-iOS/pull/12)
- Switched the app font from SF Mono to SF Pro and dropped forced all-caps text [#12](https://github.com/ekomarova/Lummi-iOS/pull/12)
- Made record cards transparent with a white border and redesigned edit/delete as labeled glass buttons [#12](https://github.com/ekomarova/Lummi-iOS/pull/12)
- Removed the iPad 1.5x scaling in favor of native sizing [#12](https://github.com/ekomarova/Lummi-iOS/pull/12)

### Fixed
- Fixed glass chrome, the calendar grid and record cards being scaled up on iPad [#12](https://github.com/ekomarova/Lummi-iOS/pull/12)
- Fixed `Clear All Data` hiding a failed delete: the `ModelContext` is now rolled back and a "Failed to Delete" alert is shown [#14](https://github.com/ekomarova/Lummi-iOS/pull/14)
- Fixed `Clear All Data` leaving an empty list after a failed save on iOS 17.0 by deleting entries in a separate `ModelContext` that is discarded on failure [#17](https://github.com/ekomarova/Lummi-iOS/pull/17)
- Removed the spring animation around the theme switch and iCloud toggle that froze the UI on iOS 17 [#17](https://github.com/ekomarova/Lummi-iOS/pull/17)

## [1.0.0] - 2026-09-17
### Added
- Added unit tests (Swift Testing) for `InsightsCalculator`, `DateExtension`, `ThemeManager` and `JoyEntry.dateKey`
- Added the `unit-tests` CI job for `iPhone 17` and `iPad Pro 13-inch (M5)` simulators
- Added CodeQL static analysis (`security-extended`) for Swift on every pull request [#7](https://github.com/ekomarova/Lummi-iOS/pull/7)
- Added code coverage via Codecov [#10](https://github.com/ekomarova/Lummi-iOS/pull/10)
- Added the `ui-tests` CI job on `iPhone 17` [#11](https://github.com/ekomarova/Lummi-iOS/pull/11)

### Fixed
- Fixed the calendar grid being misaligned with the weekday header for English on Monday-first regions: `SingleMonthView` now uses the in-app locale instead of `Calendar.current`
- Blurred background content when the "new record" sheet is open on iPad
- Fixed a UI freeze on iOS 17.0 when opening `Calendar` or `Insights` after switching language, caused by creating `DateFormatter` instances on every render of `WeekdayHeaderView`
- Fixed the same freeze in `InsightsCalculator.calculateGoldenHours` by replacing `setLocalizedDateFormatFromTemplate("jmm")` with `Date.FormatStyle`
- Fixed a crash in `CloudKitSyncMonitor.init()` in builds without a signed iCloud entitlement [#11](https://github.com/ekomarova/Lummi-iOS/pull/11)
- Fixed flaky `LummiUITests` in CI with looser timeouts, waiting for animations and no simulator-clone parallelization [#11](https://github.com/ekomarova/Lummi-iOS/pull/11)

## [1.0.0rc3] - 2026-09-04
### Added
- Added `SaveFailureUITests` and the `-UI_TESTING_SIMULATE_SAVE_FAILURE` launch argument to test save, edit and delete failures

### Fixed
- Fixed silent data loss when `try? modelContext.save()` failed in `RecordInput` and `SelectedDayDetailView`: the context is now rolled back and an error alert is shown
- Added missing Russian and German translations for three error-alert strings
- Fixed the `Sync issue: %@` banner in `Settings` missing the `%@` placeholder in all languages

### Performance
- Replaced per-call `DateFormatter` allocations with a static formatter in `Date.stringKey` and a cached `Date.format(_:locale:)`

### Refactored
- Replaced the `asyncAfter(+0.1s)` timer in `SelectedDayDetailView` with `.onChange(of: isEditing)`
- Merged `InsightGlowCard` and `RhythmGlowCard` into a single `GlowCard`

## [1.0.0rc2] - 2026-09-02
### Added
- Capped joy entry text at 280 characters with a live character counter

### Changed
- Aligned `IPHONEOS_DEPLOYMENT_TARGET` across all targets (tests inherited iOS 26.4 instead of iOS 17)
- Pinned `SWIFT_VERSION = 5.0` and updated README requirements to iOS 17.6+ and Swift 5.0+
- Blurred the background behind the `Clear All Data` confirmation dialog

### Fixed
- Fixed the `Release` build failing because `MockDataManager` leaked into the main target
- Fixed editing or deleting the wrong entry when two entries shared a date by tracking the selection by `PersistentIdentifier`
- Fixed a `fatalError` when toggling iCloud sync if `ModelContainer` failed to reinitialize; the toggle now reverts with an error dialog
- Fixed the iCloud error banner flashing when the sync toggle reverted
- Fixed the "iCloud storage is full" banner staying visible after storage was freed

### Refactored
- Migrated `ThemeManager` from `Combine` to `Observation` (`@Observable`)
- Made `JoyEntry.dateKey` a computed property derived from `date`

## [1.0.0rc1] - 2026-09-01
### Added
- Encrypted journal entry text when synced via iCloud
- Added `Clear All Data` in `Settings` to delete all entries locally and from iCloud
- Added opt-in iCloud sync across Apple devices in `Settings`
- Added a warning banner in `Settings` when iCloud sync cannot complete (no Apple ID, full storage, restrictions)
- Added a GitHub Actions CI workflow that builds, analyzes and compiles the app and tests on pull requests to master

### Changed
- Made iCloud sync toggling apply instantly without an app restart
- Redesigned the `Settings` switches as segmented controls for Appearance and iCloud Sync
- Raised the minimum iOS version to 17.0 for native `SwiftData`
- Changed `Joyful Hours` to prefer the most recent active hour when hours tie

### Fixed
- Fixed UI tests related to `ModelContainer` initialization
- Fixed the language picker text being too small on iPad
- Fixed the layout bouncing when the iCloud sync error banner appeared
- Fixed iCloud rate-limiting by saving changes when typing finishes or the screen closes instead of on every keystroke

### Refactored
- Improved `ModelContainer` initialization

## [0.3.0] - 2026-05-11
### Added
- Added the `Joyful Hours` metric showing the time of day with the most joy
- Added a `Tap here` hint to the monthly list card

### Changed
- Redesigned the visual language of the `Insights` screen

### Fixed
- Fixed the moments list flying across the `Insights` screen when expanded

### Refactored
- Moved analytics logic to `InsightsCalculator`

## [0.2.1] - 2026-05-08
### Added
- Added the new app icon
- Added an expandable monthly archive in `Insights` to revisit joys from a specific month

### Changed
- Simplified the `Joys` and `Day streak` cards

### Fixed
- Fixed inconsistent width and spacing of insight cards

## [0.2.0] - 2026-05-06
### Added
- Added the `Monthly Comparison` insight comparing the current month with the previous one
- Added Russian and German translations with String Catalogs
- Added an in-app language picker in `Settings` (English, Russian, German)

### Changed
- Improved the `Insights` layout by alternating circular badges and wide rectangular blocks

### Fixed
- Fixed dates not updating their language
- Fixed the month comparison message overflowing its container on iPad and larger screens

### Refactored
- Switched UI tests to language-agnostic identifiers

## [0.1.0] - 2026-05-02
### Added
- Added an expandable calendar with month navigation and "oldest record" detection
- Added creating, reading, updating and deleting `Joy Entries`
- Integrated SwiftData with disk storage and an in-memory mode for tests
- Added `ThemeManager` with Light/Dark mode and custom color palettes
- Added a monthly `Insights` dashboard with total joys and longest daily streak
- Added adaptive `Insights` messages based on entry count and streak
- Added an XCUITest suite covering `Insights` navigation, record management and `Settings`
