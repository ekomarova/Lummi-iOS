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
            date.format("d MMMM yyyy", locale: locale).uppercased()
        }
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                Text(headerDateText)
                    .font(.lummiFont(size: 24))
                    .foregroundColor(themeManager.currentTheme.textColor)
                    .accessibilityIdentifier("HeaderDateText")

                Image(systemName: "chevron.down")
                    .font(.lummiFont(size: 20))
                    .foregroundColor(themeManager.currentTheme.textColor.opacity(0.6))
                    .rotationEffect(.degrees(isExpanded ? 180 : 0))
                    .offset(y: 1)
            }
            .contentShape(Rectangle())
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("HeaderToggleButton")
        .frame(maxWidth: .infinity, alignment: .center)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isExpanded)
    }
}
