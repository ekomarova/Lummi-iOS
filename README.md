# Lummi 🌟

[![coverage](https://codecov.io/gh/ekomarova/Lummi-iOS/branch/main/graph/badge.svg)](https://codecov.io/gh/ekomarova/Lummi-iOS/branch/main)

**Lummi** is a minimalist joy journal designed to capture happy moments and track emotional progress. The application is built using the **SwiftUI + SwiftData** stack, with a strong emphasis on high testability and modularity

## License

This project is licensed under the [PolyForm Noncommercial License 1.0.0](https://polyformproject.org/licenses/noncommercial/1.0.0).

Free to use, modify, and share for personal, educational, and other non-commercial purposes. Commercial use is not permitted without prior written permission from the author.

See [LICENSE](./LICENSE.md) for the full terms.

## 🚀 Features

* **Joy Journal**: Create, edit, and delete daily "moments of joy"
* **Smart Calendar**: Intuitive navigation through days and months to review your history
* **Insights**: Comprehensive monthly analytics designed to help you understand your happiness patterns: 
    *   Track the volume of positive moments captured each month
    *   Discover your "peak joy" time window through intelligent time-density analysis
    *   Instant access to your full monthly history with interactive, beautifully blurred data cards
* **Dynamic Themes**: Full support for Light and Dark modes managed via a custom `ThemeManager`
* **Seamless iCloud Sync:** Keep your joyful moments safe and synchronized across your iPhone and iPad (Opt-in via Settings)
* **Multi-language Support**: English, Russian, German

## 🔒 Privacy
Your data is yours. Using SwiftData and CloudKit, the text of your moments is encrypted during iCloud sync (`.allowsCloudEncryption`). Apple handles the secure key management, meaning your entries stay private and safe.

## 🏗 Architecture

* **Localization**: Uses modern **String Catalogs (.xcstrings)** for manageable translations and **LocalizedStringResource** for type-safe code strings
* **Data Layer & Sync**: Powered by **SwiftData** for reliable persistence + **CloudKit**
* **Testing Support**: Features a specialized `isStoredInMemoryOnly` mode for UI testing to ensure user data remains untouched during automation

## 🧪 Testing

### Unit & UI Tests
* **Unit tests** are written with the **Swift Testing** framework (`import Testing`) and cover all testable business logic.
* **UI tests** are written with **XCUITest** and cover end-to-end user flows: calendar navigation, record creation/edit/delete, insights display, settings, iCloud sync toggle, and save failure paths.

### Mocking
A dedicated `MockDataManager` (under `#if DEBUG`) populates the database with specific states based on launch arguments, allowing robust UI testing of various scenarios without touching real user data.

## 🤖 AI-assisted development (Claude Code)

The repository ships with [Claude Code](https://claude.com/claude-code) configuration, so contributors using it get the same conventions and safety checks automatically:

| File | What it does |
|---|---|
| `CLAUDE.md` | Project conventions loaded into every session: layout, git flow, code style, localization, theming, CloudKit model rules, testing and changelog requirements |
| `.claude/settings.json` + `.claude/hooks/pre-commit.sh` | Hook that runs before every `git commit` made by Claude: blocks the commit if SwiftLint fails and restores `DEVELOPMENT_TEAM = "$(DEVELOPMENT_TEAM)";` in `project.pbxproj` (Xcode overwrites it with automatic signing) |
| `.claude/skills/refactor-analysis` | On-demand `/refactor-analysis [path]`: read-only search for duplicated code, hardcoded values and hacks, and design weaknesses, with a summary and a table of proposed improvements |
| `.claude/skills/audit` | On-demand `/audit [path]`: read-only audit of bugs, security, code quality, licenses, git hygiene and release readiness, with a prioritized report |

## 💻 Setup & Requirements

* **iOS 17.6+** (native Liquid Glass on iOS 26+, with a graceful fallback below that)
* **Xcode 26.0+**
* **Swift 5.x**

## How to run:
**To enable iCloud sync in your own fork**:
* Change the Bundle Identifier in Target Settings
* Select your own Development Team
* In Signing & Capabilities, remove the existing iCloud container and add a new one with your own identifier
