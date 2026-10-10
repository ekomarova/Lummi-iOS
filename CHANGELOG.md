# Changelog

All notable changes to the project will be documented in this file.
## [1.3.0] - 2026-MM-DD
### Changed
- Replaced the custom bottom toolbar with the native tab bar [#52](https://github.com/ekomarova/Lummi-iOS/pull/52)
- Updated the app theme [#54](https://github.com/ekomarova/Lummi-iOS/pull/54)

## [1.2.1] - 2026-10-09
### Fixed
- Showed the iCloud sync banner in `Settings`: the sync monitor never started, so a signed-out account or full iCloud storage went unnoticed [#53](https://github.com/ekomarova/Lummi-iOS/pull/53)

## [1.2.0] - 2026-10-08
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
- Kept the "iCloud storage is full" message while uploads still fail, and recognized a full iCloud storage reported inside a partial failure [#47](https://github.com/ekomarova/Lummi-iOS/pull/47)
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
