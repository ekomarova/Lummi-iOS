//
//  Required Notice: Copyright Evseniia Komarova (https://github.com/ekomarova)
//
//  Licensed under the PolyForm Noncommercial License 1.0.0.
//  See the LICENSE file in the repository root for full terms.
//  <https://polyformproject.org/licenses/noncommercial/1.0.0>
//

import CoreGraphics

// Shared spacing for pages pushed onto a tab's navigation stack.
enum PageSpacing {
    // Top inset of a page that starts with a control such as `PeriodTabPicker`, which has padding of its own.
    static let topBelowControl: CGFloat = 13
    // Top inset of a page that starts directly with a list of rows or cards.
    static let topBelowList: CGFloat = 18
}
