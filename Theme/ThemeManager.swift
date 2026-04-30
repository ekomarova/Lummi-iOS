//
//  Theme Switch
//

import SwiftUI
import Combine

class ThemeManager: ObservableObject {
    @Published var isDark: Bool = UserDefaults.standard.object(forKey: "isDarkMode") as? Bool ?? true {
        didSet {
            UserDefaults.standard.set(isDark, forKey: "isDarkMode")
            currentTheme = isDark ? DarkTheme() : LightTheme()
        }
    }
    
    @Published var currentTheme: AppTheme
    
    init() {
        let savedIsDark = UserDefaults.standard.object(forKey: "isDarkMode") as? Bool ?? true
        self.currentTheme = savedIsDark ? DarkTheme() : LightTheme()
    }
}
