//
//  Copyright (c) 2026, Evseniia Komarova.
//  All rights reserved.
//
//  Licensed under the PolyForm Noncommercial License 1.0.0.
//  See the LICENSE file in the repository root for full terms.
//  <https://polyformproject.org/licenses/noncommercial/1.0.0>
//

// Shared opacity levels for the "card" fill + stroke look used across
// settings rows, capsule rows and glow cards.
enum CardOpacity {
    // Default fill opacity for the card background, e.g. `cardBackground`'s default.
    static let fill: Double = 0.05
    // Default stroke opacity paired with `fill`.
    static let stroke: Double = 0.1
    // Stronger stroke used where a card has no matching plain fill, e.g. GlowCard's gradient background.
    static let prominentStroke: Double = 0.15
}
