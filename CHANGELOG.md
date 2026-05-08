# Changelog

All notable changes to the project will be documented in this file.

## [0.3.0] - 2026-MM-DD
### Added
- **New App Icon**: Introduced the App branding

### Changed
- **Metric Cards**: Simplified "Joys" and "Day streak" cards for better readability

---

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

---

## [0.1.0] - 2026-05-02

### Added
- **Smart Calendar**: Built an expandable calendar with seamless month-to-month navigation and "oldest record" detection
- **Joy Journaling**: Developed full functionality (Create, Read, Update, Delete) for recording and managing daily "Joy Entries"
- **Core Persistence**: Integrated **SwiftData** with support for persistent disk storage and an in-memory mode specifically for automated testing
- **Theming**: Integrated a `ThemeManager` supporting dynamic Light and Dark mode switching with custom color palettes
- **Monthly Insights**: Created a dedicated dashboard that calculates total joys per month and identifies the longest daily streaks
- **Dynamic Messaging**: Implemented a system of adaptive messages for insights based on the number of entries and current streak status
- **UI Automation Suite**: Established a comprehensive suite of **XCUITest** scenarios covering Insights navigation, record management, and settings
