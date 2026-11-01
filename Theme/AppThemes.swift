//
//  Required Notice: Copyright Evseniia Komarova (https://github.com/ekomarova)
//
//  Licensed under the PolyForm Noncommercial License 1.0.0.
//  See the LICENSE file in the repository root for full terms.
//  <https://polyformproject.org/licenses/noncommercial/1.0.0>
//

import SwiftUI

// Concrete dark and light themes implementing AppTheme.
struct DarkTheme: AppTheme {
    var backgroundColor: Color = .black
    var cardColor: Color = Color(red: 0.11, green: 0.11, blue: 0.12)

    var textColor: Color = .white

    var bubbleColor: Color = Color(red: 0.10, green: 0.40, blue: 0.80)

    var selectedTabColor: Color = Color(red: 0.10, green: 0.40, blue: 0.80)
}

struct LightTheme: AppTheme {
    var backgroundColor: Color = Color(red: 0.95, green: 0.95, blue: 0.96)
    var cardColor: Color = .white

    var textColor: Color = .black

    // Lighter than in the dark theme, so the dark text on it stays readable
    var bubbleColor: Color = Color(red: 0.52, green: 0.76, blue: 1.0)

    // Darker than the bubbles: a pale icon would barely show on the light background
    var selectedTabColor: Color = Color(red: 0.10, green: 0.40, blue: 0.80)
}
