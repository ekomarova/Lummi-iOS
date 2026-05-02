# Lummi 🌟

**Lummi** is a minimalist joy journal designed to capture happy moments and track emotional progress. The application is built using the **SwiftUI + SwiftData** stack, with a strong emphasis on high testability and modularity.

## 🚀 Features

* **Joy Journal**: Create, edit, and delete daily "moments of joy".
* **Smart Calendar**: Intuitive navigation through days and months to review your history.
* **Insights**: Comprehensive monthly analytics, including total entry counts and the calculation of your longest streak.
* **Dynamic Themes**: Full support for Light and Dark modes managed via a custom `ThemeManager`.

## 🏗 Architecture

* **Data Layer**: Powered by **SwiftData** for reliable persistence.
* **Testing Support**: Features a specialized `isStoredInMemoryOnly` mode for UI testing to ensure user data remains untouched during automation.

## 🧪 Mocking & UI Testing

The project includes a dedicated `MockDataManager` (under `#if DEBUG`) that populates the database with specific states based on launch arguments. This allows for robust UI testing of various scenarios.

## 💻 Setup & Requirements

* **iOS 17.0+**
* **Xcode 15.0+**
* **Swift 5.9+**
