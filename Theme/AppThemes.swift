//
//  Copyright (c) 2026, Evseniia Komarova.
//  All rights reserved.
//
//  Licensed under the PolyForm Noncommercial License 1.0.0.
//  See the LICENSE file in the repository root for full terms.
//  <https://polyformproject.org/licenses/noncommercial/1.0.0>
//

import SwiftUI

struct DarkTheme: AppTheme {
    var bgGradient = LinearGradient(
        colors: [
            Color(red: 0.05, green: 0.11, blue: 0.22),
            Color.black
        ],
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
        colors: [
            Color(red: 0.93, green: 0.55, blue: 0.68),
            Color(red: 1.0, green: 0.99, blue: 0.995)
        ],
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
