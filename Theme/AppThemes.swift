//
//  Implementation of Dark and Light themes
//

import SwiftUI

struct DarkTheme: AppTheme {
    var bgGradient = LinearGradient(
        colors: [.black, .black],
        startPoint: .top, endPoint: .bottom
    )
    var backgroundColor: Color = .black
    
    var textColor: Color = .white
    var inactiveOpacity: Double = 0.35
    
    var todayColor: Color = .black
    var dayFilledColor: Color = .orange
    var calendarBackground: Color = .white
    var calendarContentColor: Color = .black
    
    var bottomPanelStarIconColor: Color = .orange
}

struct LightTheme: AppTheme {
    var bgGradient = LinearGradient(
        colors: [.white, .white],
        startPoint: .top, endPoint: .bottom
    )
    var backgroundColor: Color = .white
    
    var textColor: Color = .black
    var inactiveOpacity: Double = 0.35
    
    var todayColor: Color = .white
    var dayFilledColor: Color = .orange
    var calendarBackground: Color = .black
    var calendarContentColor: Color = .white
    
    var bottomPanelStarIconColor: Color = .orange
}
