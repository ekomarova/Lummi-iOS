import SwiftUI

protocol AppTheme {
    // Background
    var bgGradient: LinearGradient { get }
    var backgroundColor: Color { get }

    // Text
    var textColor: Color { get }
    var inactiveOpacity: Double { get }
    
    // Day
    var todayColor: Color { get }
    var dayFilledColor: Color { get }

    // Bottom panel
    var bottomPanelBackground: Color { get }
    var bottomPanelBorder: Color { get }
    var bottomPanelStarIconColor: Color { get }

    // Expanded calendar
    var calendarContentColor: Color { get }
}
