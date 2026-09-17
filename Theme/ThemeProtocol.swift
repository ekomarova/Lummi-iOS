//
//  Copyright (c) 2026, Evseniia Komarova.
//  All rights reserved.
//
//  Licensed under the PolyForm Noncommercial License 1.0.0.
//  See the LICENSE file in the repository root for full terms.
//  <https://polyformproject.org/licenses/noncommercial/1.0.0>
//

import SwiftUI

protocol AppTheme {
    // App background
    var bgGradient: LinearGradient { get }
    var backgroundColor: Color { get }

    // Text
    var textColor: Color { get }
    var inactiveOpacity: Double { get }
    
    // Calendar
    var dayFilledColor: Color { get }
    
    // Bottom panel
    var bottomPanelStarIconColor: Color { get }
}
