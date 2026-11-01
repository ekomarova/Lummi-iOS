//
//  Required Notice: Copyright Evseniia Komarova (https://github.com/ekomarova)
//
//  Licensed under the PolyForm Noncommercial License 1.0.0.
//  See the LICENSE file in the repository root for full terms.
//  <https://polyformproject.org/licenses/noncommercial/1.0.0>
//

import Foundation

// `UserDefaults` / `@AppStorage` keys shared across files. Use these instead of string literals, so a typo is a
// compile error and not a silently empty key.
enum SettingsKey {
    // The app language chosen in Settings.
    static let appLanguage = "appLanguage"
    // Whether the user opted in to iCloud sync. Decides which `ModelContainer` the app opens at launch.
    static let isICloudSyncEnabled = "isICloudSyncEnabled"
}
