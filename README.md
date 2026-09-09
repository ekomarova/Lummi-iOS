# Lummi 🌟

**Lummi** is a minimalist joy journal designed to capture happy moments and track emotional progress. The application is built using the **SwiftUI + SwiftData** stack, with a strong emphasis on high testability and modularity

## 🚀 Features

* **Joy Journal**: Create, edit, and delete daily "moments of joy"
* **Smart Calendar**: Intuitive navigation through days and months to review your history
* **Insights**: Comprehensive monthly analytics designed to help you understand your happiness patterns: 
    *   Track the volume of positive moments captured each month
    *   Discover your "peak joy" time window through intelligent time-density analysis
    *   Instant access to your full monthly history with interactive, beautifully blurred data cards
* **Dynamic Themes**: Full support for Light and Dark modes managed via a custom `ThemeManager`
* **Seamless iCloud Sync:** Keep your joyful moments safe and synchronized across your iPhone and iPad (Opt-in via Settings)
* **Multi-language Support**: 
    *   English
    *   Russian
    *   German

## 🔒 Privacy
Your data is yours. Using SwiftData and CloudKit, the text of your moments is encrypted during iCloud sync (`.allowsCloudEncryption`). Apple handles the secure key management, meaning your entries stay private and safe.

## 🏗 Architecture

* **Localization**: Uses modern **String Catalogs (.xcstrings)** for manageable translations and **LocalizedStringResource** for type-safe code strings
* **Data Layer & Sync**: Powered by **SwiftData** for reliable persistence + **CloudKit**
* **Testing Support**: Features a specialized `isStoredInMemoryOnly` mode for UI testing to ensure user data remains untouched during automation

## 🧪 Testing

### Unit Tests
Unit tests written with the **Swift Testing** framework (`import Testing`) cover all testable business logic:

| Suite | Coverage |
|---|---|
| `InsightsCalculatorTests` | `filterEntries`, `uniqueDaysCount`, `daysNeededForReport`, `longestStreak`, `calculateGoldenHours` — including edge cases: month boundaries, midnight wrap-around, tie-breaking, duplicate days |
| `DateExtensionTests` | `stringKey`, `format` (with cache), `startOfMonth`, `previousMonth`, `isCurrentMonth`, `isOldestMonth` |
| `ThemeManagerTests` | Default theme, toggle persistence to `UserDefaults`, reading saved preference on init |
| `JoyEntryTests` | `dateKey` computed property consistency |

### UI Tests
UI tests written with **XCUITest** cover end-to-end user flows: calendar navigation, record creation/edit/delete, insights display, settings, iCloud sync toggle, and save failure paths.

### Mocking
A dedicated `MockDataManager` (under `#if DEBUG`) populates the database with specific states based on launch arguments, allowing robust UI testing of various scenarios without touching real user data.

## 💻 Setup & Requirements

* **iOS 17.6+**
* **Xcode 16.0+**
* **Swift 5.x**

## How to run:
**To enable iCloud sync in your own fork**:
* Change the Bundle Identifier in Target Settings
* Select your own Development Team
* In Signing & Capabilities, remove the existing iCloud container and add a new one with your own identifier
