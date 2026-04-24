//
//  Theme Switch
//

import SwiftUI
import Combine

class ThemeManager: ObservableObject {
    @Published var isDark: Bool = true {
        didSet { currentTheme = isDark ? DarkTheme() : LightTheme() }
    }
    @Published var currentTheme: AppTheme = DarkTheme()
}
