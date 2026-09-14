//
//  Copyright (c) 2026, Evseniia Komarova.
//  All rights reserved.
//
//  Licensed under the PolyForm Noncommercial License 1.0.0.
//  See the LICENSE file in the repository root for full terms.
//  <https://polyformproject.org/licenses/noncommercial/1.0.0>
//

import SwiftUI

struct InsightsButton: View {
    @Environment(ThemeManager.self) private var themeManager
    
    var isActive: Bool
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Image(systemName: isActive ? "chart.pie.fill" : "chart.pie")
                .font(.lummiFont(size: 27))
                .foregroundColor(themeManager.currentTheme.textColor.opacity(0.8))
                .frame(width: 44, height: 44)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(isActive ? "InsightsButton_Active" : "InsightsButton_Inactive")
    }
}
