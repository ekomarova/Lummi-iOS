import SwiftUI

protocol AppTheme {
    // App background
    var bgGradient: LinearGradient { get }
    var backgroundColor: Color { get }

    // Text
    var textColor: Color { get }
    var inactiveOpacity: Double { get }
    
    //Calendar
    var calendarBackground: Color { get }
    var calendarContentColor: Color { get }
    var todayColor: Color { get }
    var dayFilledColor: Color { get }
    
    // Bottom panel
    var bottomPanelStarIconColor: Color { get }
}
