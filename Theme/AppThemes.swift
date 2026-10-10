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
    var inactiveOpacity: Double = 0.35

    var dayFilledColor: Color = Color(red: 0.6, green: 0.85, blue: 1.0)

    var recordButtonColor: Color = Color(red: 0.15, green: 0.5, blue: 0.75)
    var selectedTabColor: Color = Color(red: 0.35, green: 0.65, blue: 1.0)
}

struct LightTheme: AppTheme {
    var backgroundColor: Color = Color(red: 0.88, green: 0.88, blue: 0.89)
    var cardColor: Color = .white

    var textColor: Color = .black
    var inactiveOpacity: Double = 0.35

    var dayFilledColor: Color = Color(red: 0.10, green: 0.40, blue: 0.80)

    var recordButtonColor: Color = Color(red: 0.65, green: 0.82, blue: 0.98)
    var selectedTabColor: Color = Color(red: 0.10, green: 0.40, blue: 0.80)
}
