# Lummi 🌟

[![coverage](https://codecov.io/gh/ekomarova/Lummi-iOS/branch/main/graph/badge.svg)](https://codecov.io/gh/ekomarova/Lummi-iOS/branch/main)

**Lummi** is a minimalist joy journal designed to capture happy moments and track emotional progress. The application is built using the **SwiftUI + SwiftData** stack, with a strong emphasis on high testability and modularity

## License

This project is licensed under the [PolyForm Noncommercial License 1.0.0](https://polyformproject.org/licenses/noncommercial/1.0.0).

Free to use, modify, and share for personal, educational, and other non-commercial purposes. Commercial use is not permitted without prior written permission from the author.

See [LICENSE](./LICENSE.md) for the full terms.

## 🚀 Features

* **Joy Journal**: Create, edit, and delete daily "moments of joy"
* **Insights**: Monthly analytics designed to help you understand your happiness patterns:
    *   **Highlights**: how many moments you captured this month, your "joyful hours" (the 3-hour window of the day when joy happens most), active days and your day streak
    *   **Recall**: "All Joys" lists every moment of the current month, or of any past year from the All Time tab
    *   **Trends**: charts of joys by date (or by month for a year), by weekday, and the number of active days, for any year
* **Dynamic Themes**: Light, Dark or Auto (follows the system appearance), managed via a custom `ThemeManager`
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
* **Unit tests** are written with the **Swift Testing** framework (`import Testing`; the performance test uses XCTest) and cover all testable business logic.
* **UI tests** are written with **XCUITest** and cover end-to-end user flows: record creation/edit/delete, insights and trends, settings, iCloud sync toggle, save failure and storage error paths. Performance UI tests on a 5,000-entry store are manual (`RUN_PERFORMANCE_TESTS=1`).

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
| `.claude/skills/performance-profile` | On-demand `/performance-profile [scenarios]`: read-only Time Profiler run of launch, adding a record, Insights, All Joys and Trends on a simulator, with the cost per app function and fix options rated by complexity. Needs `defusedxml` (`python3 -m pip install defusedxml`) |

## 💻 Setup & Requirements

* **iOS 18.0+** (native Liquid Glass on iOS 26+, with a graceful fallback below that)
* **Xcode 26.0+**
* **Swift 5.x**

## How to run

Signing and iCloud settings are not stored in the project. They come from `Local.xcconfig`, which is git-ignored, so a fresh clone does not have it. Without it `DEVELOPMENT_TEAM` and `ICLOUD_CONTAINER_ID` are empty, and the app will not be signed or will not get an iCloud container.

1. Create your local config from the template:
   ```sh
   cp Local.xcconfig.example Local.xcconfig
   ```
2. Edit `Local.xcconfig`:
   ```
   DEVELOPMENT_TEAM = ABCDE12345                      # your 10-character Team ID
   ICLOUD_CONTAINER_ID = iCloud.com.example.Lummi     # your iCloud container
   ```
   Find the Team ID in your `Apple Developer account` under `Membership details`.
3. Open `Lummi.xcodeproj` and run the **Lummi** scheme.

**To run in your own fork**, also change the Bundle Identifier of the app target (and the test targets) in Target Settings, and make `ICLOUD_CONTAINER_ID` match it, for example `iCloud.<your bundle id>`. Xcode registers the container for your team on the first signed build.

Do not select the team in Signing & Capabilities: Xcode would write it into `project.pbxproj` and it could be committed by accident. Keep it in `Local.xcconfig`.
