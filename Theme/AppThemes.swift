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

    var bottomPanelBackground: Color = .white
    var bottomPanelBorder: Color = .white
    var bottomPanelStarIconColor: Color = .orange
    var calendarContentColor: Color = .black
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

    var bottomPanelBackground: Color = .black
    var bottomPanelBorder: Color = .black
    var bottomPanelStarIconColor: Color = .orange
    var calendarContentColor: Color = .white
}
