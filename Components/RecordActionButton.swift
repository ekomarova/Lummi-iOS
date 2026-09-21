//
//  Copyright (c) 2026, Evseniia Komarova.
//  All rights reserved.
//
//  Licensed under the PolyForm Noncommercial License 1.0.0.
//  See the LICENSE file in the repository root for full terms.
//  <https://polyformproject.org/licenses/noncommercial/1.0.0>
//

import SwiftUI

// Capsule-shaped button with a title, used for Edit/Delete actions
struct RecordActionButton: View {
    @Environment(ThemeManager.self) private var themeManager

    let systemImage: String
    let title: LocalizedStringKey
    let accessibilityID: String
    let action: () -> Void

    var body: some View {
        Button(
            action: action,
            label: {
                HStack(spacing: 6) {
                    Image(systemName: systemImage)
                        .font(.lummiFont(size: 14))
                    Text(title)
                        .font(.lummiFont(size: 14))
                }
                .foregroundColor(themeManager.currentTheme.textColor)
                .padding(.horizontal, 16)
                .frame(height: 44)
                .adaptiveGlass(in: Capsule())
            }
        )
        .accessibilityIdentifier(accessibilityID)
    }
}

#if DEBUG
#Preview {
    HStack(spacing: 12) {
        RecordActionButton(systemImage: "pencil", title: "Edit", accessibilityID: "PreviewEdit", action: { })
        RecordActionButton(systemImage: "trash", title: "Delete", accessibilityID: "PreviewDelete", action: { })
    }
    .previewEnvironment()
}
#endif
