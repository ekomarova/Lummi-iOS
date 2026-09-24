//
//  Copyright (c) 2026, Evseniia Komarova.
//  All rights reserved.
//
//  Licensed under the PolyForm Noncommercial License 1.0.0.
//  See the LICENSE file in the repository root for full terms.
//  <https://polyformproject.org/licenses/noncommercial/1.0.0>
//

import SwiftUI
import Observation

// Holds the current theme and persists the dark/light choice in UserDefaults.
@Observable
class ThemeManager {
    var isDark: Bool = UserDefaults.standard.object(forKey: "isDarkMode") as? Bool ?? true {
        didSet {
            UserDefaults.standard.set(isDark, forKey: "isDarkMode")
            currentTheme = isDark ? DarkTheme() : LightTheme()
        }
    }
    
    var currentTheme: AppTheme
    
    init() {
        let savedIsDark = UserDefaults.standard.object(forKey: "isDarkMode") as? Bool ?? true
        self.currentTheme = savedIsDark ? DarkTheme() : LightTheme()
    }
}
