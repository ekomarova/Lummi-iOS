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

    var selectedTabColor: Color = Color(red: 0.35, green: 0.65, blue: 1.0)
}

struct LightTheme: AppTheme {
    var backgroundColor: Color = Color(red: 0.95, green: 0.95, blue: 0.96)
    var cardColor: Color = .white

    var textColor: Color = .black

    var selectedTabColor: Color = Color(red: 0.10, green: 0.40, blue: 0.80)
}
