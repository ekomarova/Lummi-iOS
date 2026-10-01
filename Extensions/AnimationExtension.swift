//
//  Copyright (c) 2026, Evseniia Komarova.
//  All rights reserved.
//
//  Licensed under the PolyForm Noncommercial License 1.0.0.
//  See the LICENSE file in the repository root for full terms.
//  <https://polyformproject.org/licenses/noncommercial/1.0.0>
//

import SwiftUI

// The app's shared spring animation, used for every screen transition and toggle.
extension Animation {
    static var lummiSpring: Animation {
        .spring(response: 0.35, dampingFraction: 0.82)
    }
}
