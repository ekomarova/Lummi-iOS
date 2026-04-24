import SwiftUI

protocol AppTheme {
    var bgGradient: LinearGradient { get }
    var textColor: Color { get }
    var inactiveOpacity: Double { get }
    
    // Starts
    var starPrimary: Color { get }
    var starSecondary: Color { get }
    var starBlurRadius: CGFloat { get }
    
    // Today day
    var todayColor: Color { get }
    var todayGlow: Color { get }

    // Bottom panel
    var bottomPanelBackground: Color { get }
    var bottomPanelBorder: Color { get }
    var bottomPanelIconColor: Color { get }
}
