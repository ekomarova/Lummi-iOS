//
//  Copyright (c) 2026, Evseniia Komarova.
//  All rights reserved.
//
//  Licensed under the PolyForm Noncommercial License 1.0.0.
//  See the LICENSE file in the repository root for full terms.
//  <https://polyformproject.org/licenses/noncommercial/1.0.0>
//

import SwiftUI

// Circular button, used for back/save and left/right navigation
struct NavigationIconButton: View {
    @Environment(ThemeManager.self) private var themeManager

    let systemImage: String
    var size: CGFloat = 44
    var iconOpacity: Double = 1
    var accessibilityLabel: LocalizedStringKey?
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
                    .frame(width: size, height: size)
                    .overlay(
                        Image(systemName: systemImage)
                            .font(.lummiFont(size: 16, weight: .bold))
                            .foregroundColor(themeManager.currentTheme.textColor.opacity(iconOpacity))
                    )
            }
        )
        .buttonStyle(.plain)
        if let accessibilityLabel {
            base.accessibilityLabel(accessibilityLabel)
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
        NavigationIconButton(systemImage: "chevron.left", size: 36, iconOpacity: 0.8, accessibilityID: "PreviewPrev", action: { })
        NavigationIconButton(systemImage: "chevron.right", size: 36, iconOpacity: 0.8, accessibilityID: "PreviewNext", action: { })
    }
    .previewEnvironment()
}
#endif
