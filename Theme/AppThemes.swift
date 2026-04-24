//
//  Implementation of Dark and Light themes
//

import SwiftUI

struct DarkTheme: AppTheme {
    var bgGradient = LinearGradient(
        colors: [.black, .black],
        startPoint: .top, endPoint: .bottom
    )
    
    var textColor: Color = .white
    var inactiveOpacity: Double = 0.35
    
    var starPrimary: Color = .yellow
    var starSecondary: Color = .orange
    var starBlurRadius: CGFloat = 20
    
    var todayColor: Color = Color(red: 0.5, green: 0.9, blue: 1.0)
    var todayGlow: Color = .blue

    var bottomPanelBackground: Color = .white
    var bottomPanelBorder: Color = .white
    var bottomPanelIconColor: Color = .black
}

struct LightTheme: AppTheme {
    var bgGradient = LinearGradient(
        colors: [.white, .white],
        startPoint: .top, endPoint: .bottom
    )
    
    var textColor: Color = .black
    var inactiveOpacity: Double = 0.2
    
    var starPrimary: Color = .orange
    var starSecondary: Color = .yellow.opacity(0.5)
    var starBlurRadius: CGFloat = 15
    
    var todayColor: Color = .blue
    var todayGlow: Color = .cyan

    var bottomPanelBackground: Color = .black
    var bottomPanelBorder: Color = .black
    var bottomPanelIconColor: Color = .white
}
