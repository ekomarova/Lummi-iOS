//
//  Copyright (c) 2026, Evseniia Komarova.
//  All rights reserved.
//
//  Licensed under the PolyForm Noncommercial License 1.0.0.
//  See the LICENSE file in the repository root for full terms.
//  <https://polyformproject.org/licenses/noncommercial/1.0.0>
//

import SwiftUI

struct HeaderView: View {
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.locale) var locale

    let date: Date
    let isExpanded: Bool
    let onTap: () -> Void

    private var headerDateText: String {
        if isExpanded {
            date.format("LLLL yyyy", locale: locale).capitalizedFirstLetter
        } else {
            "\(date.format("d", locale: locale)) \(date.format("MMMM", locale: locale).capitalizedFirstLetter)"
        }
    }

    var body: some View {
        Button(action: onTap) {
            Text(headerDateText)
                .font(.lummiFont(size: 24))
                .foregroundColor(themeManager.currentTheme.textColor)
                .accessibilityIdentifier("HeaderDateText")
                .padding(.horizontal, 26)
                .padding(.vertical, 10)
                .adaptiveGlass(in: Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("HeaderToggleButton")
        .frame(maxWidth: .infinity, alignment: .center)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isExpanded)
        .sensoryFeedback(.selection, trigger: isExpanded)
    }
}
