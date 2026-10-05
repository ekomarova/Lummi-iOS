//
//  Copyright (c) 2026, Evseniia Komarova.
//  All rights reserved.
//
//  Licensed under the PolyForm Noncommercial License 1.0.0.
//  See the LICENSE file in the repository root for full terms.
//  <https://polyformproject.org/licenses/noncommercial/1.0.0>
//

import SwiftUI

// Circular button, used for back/save
struct NavigationIconButton: View {
    @Environment(ThemeManager.self) private var themeManager

    let systemImage: String
    var iconOpacity: Double = 1
    var accessibilityLabel: LocalizedStringResource?
    let accessibilityID: String
    let action: () -> Void

    var body: some View {
        button
            .accessibilityIdentifier(accessibilityID)
    }

    @ViewBuilder
    private var button: some View {
        let base = Button(
            action: action,
            label: {
                Circle()
                    .fill(themeManager.currentTheme.textColor.opacity(CardOpacity.fill))
                    .adaptiveGlass(in: Circle())
                    .frame(width: 44, height: 44)
                    .overlay(
                        Image(systemName: systemImage)
                            .font(.lummiFont(size: 16, weight: .bold))
                            .foregroundColor(themeManager.currentTheme.textColor.opacity(iconOpacity))
                    )
            }
        )
        .buttonStyle(.plain)
        if let accessibilityLabel {
            base.accessibilityLabel(Text(accessibilityLabel))
        } else {
            base
        }
    }
}

#if DEBUG
#Preview {
    HStack(spacing: 20) {
        NavigationIconButton(systemImage: "chevron.left", accessibilityID: "PreviewBack", action: { })
        NavigationIconButton(systemImage: "checkmark", iconOpacity: 0.2, accessibilityID: "PreviewSave", action: { })
    }
    .previewEnvironment()
}
#endif
