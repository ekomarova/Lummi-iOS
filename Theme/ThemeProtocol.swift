//
//  Required Notice: Copyright Evseniia Komarova (https://github.com/ekomarova)
//
//  Licensed under the PolyForm Noncommercial License 1.0.0.
//  See the LICENSE file in the repository root for full terms.
//  <https://polyformproject.org/licenses/noncommercial/1.0.0>
//

import SwiftUI

// Contract for a theme: the colors every theme must provide.
protocol AppTheme {
    // App background
    var backgroundColor: Color { get }

    // Cards: settings blocks, list rows, joys
    var cardColor: Color { get }

    // Text
    var textColor: Color { get }

    // Joy bubbles. The text on a bubble is `textColor`.
    var bubbleColor: Color { get }

    // Icon and label of the selected tab in the tab bar
    var selectedTabColor: Color { get }
}

extension AppTheme {
    // Secondary text, such as axis labels and month captions.
    var secondaryTextColor: Color { textColor.opacity(0.5) }

    // Faint text, such as an empty-state hint.
    var tertiaryTextColor: Color { textColor.opacity(0.3) }
}
