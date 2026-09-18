//
//  Copyright (c) 2026, Evseniia Komarova.
//  All rights reserved.
//
//  Licensed under the PolyForm Noncommercial License 1.0.0.
//  See the LICENSE file in the repository root for full terms.
//  <https://polyformproject.org/licenses/noncommercial/1.0.0>
//

import SwiftUI

struct ThemeOptionButton: View {
    @Environment(ThemeManager.self) private var themeManager

    let title: LocalizedStringKey
    let isSelected: Bool
    let accessibilityID: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Text(title)
                    .font(.lummiFont(size: 16))
                    .foregroundColor(themeManager.currentTheme.textColor)

                ZStack {
                    Circle()
                        .fill(isSelected ? Color.blue : Color.clear)
                        .overlay(
                            Circle()
                                .stroke(themeManager.currentTheme.textColor.opacity(isSelected ? 0 : 0.3), lineWidth: 1.5)
                        )

                    Image(systemName: "checkmark")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                        .opacity(isSelected ? 1 : 0)
                }
                .frame(width: 26, height: 26)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(accessibilityID)
        .accessibilityValue(isSelected ? Text("Selected") : Text("Unselected"))
    }
}
