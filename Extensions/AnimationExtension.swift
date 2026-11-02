//
//  Required Notice: Copyright Evseniia Komarova (https://github.com/ekomarova)
//
//  Licensed under the PolyForm Noncommercial License 1.0.0.
//  See the LICENSE file in the repository root for full terms.
//  <https://polyformproject.org/licenses/noncommercial/1.0.0>
//

import SwiftUI

// The app's shared spring animations. Use these instead of inline `.spring(...)` values.
extension Animation {
    // The default: screen transitions, toggles and most state changes.
    static var lummiSpring: Animation {
        .spring(response: 0.35, dampingFraction: 0.82)
    }

    // A calmer spring for larger layout changes, like switching the selected day.
    static var lummiSpringSlow: Animation {
        .spring(response: 0.4, dampingFraction: 0.8)
    }

    // A snappier, bouncier spring for direct touch feedback, like a long press.
    static var lummiSpringQuick: Animation {
        .spring(response: 0.3, dampingFraction: 0.7)
    }
}
