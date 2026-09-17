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
            date.format("LLLL yyyy", locale: locale).uppercased()
        } else {
            date.format("d MMMM", locale: locale).uppercased()
        }
    }

    var body: some View {
        Button(action: onTap) {
            Text(headerDateText)
                .font(.lummiFont(size: 24))
                .foregroundColor(themeManager.currentTheme.textColor)
                .accessibilityIdentifier("HeaderDateText")
                .padding(.horizontal, AdaptiveLayout.getSize(for: 26))
                .padding(.vertical, AdaptiveLayout.getSize(for: 10))
                .glassEffect(.clear.interactive(), in: .capsule)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("HeaderToggleButton")
        .frame(maxWidth: .infinity, alignment: .center)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isExpanded)
        .sensoryFeedback(.selection, trigger: isExpanded)
    }
}
