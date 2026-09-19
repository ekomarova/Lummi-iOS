# Lummi iOS

Minimalist joy journal app. SwiftUI + SwiftData, opt-in iCloud sync via CloudKit, iOS 17.6+, Xcode 26.0+, Swift 5.x.
Supported languages: English, Russian, German.

## Project layout
- `App/`: app entry point
- `Views/`: SwiftUI screens
- `Components/`: reusable UI components
- `DataModels/`: SwiftData models
- `Extensions/`, `Helpers/`: shared utilities
- `Theme/`: ThemeManager, colors, fonts
- `Resources/`: String Catalogs, assets
- `LummiTests/`: unit tests. `LummiUITests/`: UI tests. `TestHelpers/`: shared test utilities

## Git
- Before committing, check the current branch with `git branch --show-current`.
- If the branch is `main` (or `master`) and there are uncommitted changes, create a new branch named after the changes (`feature/...`, `fix/...`, `chore/...`, kebab-case) and commit there.
- Exception: if I explicitly ask to commit to `main`, commit to `main`.
- Commit messages: English, imperative mood, subject line up to 72 characters.

## Before every commit
1. Run `swiftlint`. If it fails, fix the violations in the code and run it again until it passes. Never commit while it fails. This is also enforced by `.claude/hooks/pre-commit.sh`.
2. In `Lummi.xcodeproj/project.pbxproj`, every `DEVELOPMENT_TEAM` must be exactly `DEVELOPMENT_TEAM = "$(DEVELOPMENT_TEAM)";`. Xcode overwrites it on automatic signing; `.claude/hooks/pre-commit.sh` restores the value and re-stages the file automatically, so no manual retry is needed.

## Code style
- SwiftLint config lives in `.swiftlint.yml`. Do not disable rules, add `swiftlint:disable` comments, or edit the config to make lint pass without asking me first.
- No force unwrapping (`!`). Use `guard let`, `if let` or `??`.
- Keep lines under 150 characters.
- All user-facing text goes through the String Catalog (`.xcstrings`) and `LocalizedStringResource`, with en, ru and de translations added together. No hardcoded strings.
- Colors and fonts come only from `Theme` / `ThemeManager`. No hardcoded values in views.
- SwiftUI: keep views small and extract subviews, mark `@State` as `private`, add a `#Preview` for every new view, add accessibility labels to interactive elements.
- SwiftData models synced via CloudKit: give every property a default value or make it optional, no `@Attribute(.unique)`, relationships optional.
- Put new files in the matching folder from Project layout.

## Testing
- New business logic needs unit tests, including edge cases.
- UI tests use XCUITest with `MockDataManager` (under `#if DEBUG`) and launch arguments. Never touch real user data.

## Changelog
- For user-visible changes, add an entry to `CHANGELOG.md`.
