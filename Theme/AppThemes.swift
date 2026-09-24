//
//  Copyright (c) 2026, Evseniia Komarova.
//  All rights reserved.
//
//  Licensed under the PolyForm Noncommercial License 1.0.0.
//  See the LICENSE file in the repository root for full terms.
//  <https://polyformproject.org/licenses/noncommercial/1.0.0>
//

import SwiftUI

// Concrete dark and light themes implementing AppTheme.
struct DarkTheme: AppTheme {
    private let topGradientColor = Color(red: 0.05, green: 0.11, blue: 0.22)

    var bgGradient: LinearGradient {
        LinearGradient(colors: [topGradientColor, .black], startPoint: .top, endPoint: .bottom)
    }
    var backgroundColor: Color = .black

    var textColor: Color = .white
    var inactiveOpacity: Double = 0.35

    var dayFilledColor: Color = Color(red: 0.6, green: 0.85, blue: 1.0)

    var recordButtonColor: Color { topGradientColor }
}

struct LightTheme: AppTheme {
    private let topGradientColor = Color(red: 0.93, green: 0.55, blue: 0.68)

    var bgGradient: LinearGradient {
        LinearGradient(
            colors: [topGradientColor, Color(red: 1.0, green: 0.99, blue: 0.995)],
            startPoint: .top, endPoint: .bottom
        )
    }
    var backgroundColor: Color = .white

    var textColor: Color = .black
    var inactiveOpacity: Double = 0.35

    var dayFilledColor: Color = Color(red: 0.75, green: 0.15, blue: 0.4)

    var recordButtonColor: Color = Color(red: 0.92, green: 0.65, blue: 0.75)
}
