//
//  Implementation of Dark and Light themes
//

import SwiftUI

struct DarkTheme: AppTheme {
    var bgGradient = LinearGradient(
        stops: [
            .init(color: Color(red: 0.25, green: 0.28, blue: 0.45), location: 0.0),
            .init(color: Color(red: 0.10, green: 0.10, blue: 0.22), location: 0.45),
            .init(color: .black, location: 1.0)
        ],
        startPoint: .top, endPoint: .bottom
    )
    
    var textColor: Color = .white
    var inactiveOpacity: Double = 0.35
    
    var starPrimary: Color = .yellow
    var starSecondary: Color = .orange
    var starBlurRadius: CGFloat = 20
    
    var todayColor: Color = Color(red: 0.5, green: 0.9, blue: 1.0)
    var todayGlow: Color = .blue

    var bottomPanelBackground: Color = .white.opacity(0.08)
    var bottomPanelBorder: Color = .white.opacity(0.08)
    var bottomPanelButtonColor: Color = Color(red: 0.5, green: 0.9, blue: 1.0)
    var bottomPanelButtonShadow: Color = .blue.opacity(0.25)
    var bottomPanelIconColor: Color = .black
}

struct LightTheme: AppTheme {
    var bgGradient = LinearGradient(
        colors: [Color(red: 0.9, green: 0.95, blue: 1.0), .white],
        startPoint: .top, endPoint: .bottom
    )
    
    var textColor: Color = .black
    var inactiveOpacity: Double = 0.2
    
    var starPrimary: Color = .orange
    var starSecondary: Color = .yellow.opacity(0.5)
    var starBlurRadius: CGFloat = 15
    
    var todayColor: Color = .blue
    var todayGlow: Color = .cyan

    var bottomPanelBackground: Color = .black.opacity(0.08)
    var bottomPanelBorder: Color = .black.opacity(0.08)
    var bottomPanelButtonColor: Color = .blue
    var bottomPanelButtonShadow: Color = .cyan.opacity(0.25)
    var bottomPanelIconColor: Color = .black
}
