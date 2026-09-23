//
//  Copyright (c) 2026, Evseniia Komarova.
//  All rights reserved.
//
//  Licensed under the PolyForm Noncommercial License 1.0.0.
//  See the LICENSE file in the repository root for full terms.
//  <https://polyformproject.org/licenses/noncommercial/1.0.0>
//

import SwiftUI

// Full-width capsule row with a subtle fill and border, used for Settings rows and the "Show All Joys" button
struct CapsuleRow<Content: View>: View {
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .frame(maxWidth: .infinity, minHeight: 31, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .cardBackground(Capsule())
    }
}

#if DEBUG
private struct CapsuleRowPreview: View {
    @Environment(ThemeManager.self) private var themeManager

    var body: some View {
        VStack(spacing: 12) {
            CapsuleRow {
                HStack {
                    Text("Show All Joys")
                    Spacer()
                    Image(systemName: "chevron.right")
                }
            }
            CapsuleRow {
                Text("Delete")
            }
        }
        .font(.lummiFont(size: 17))
        .foregroundColor(themeManager.currentTheme.textColor)
        .padding(.horizontal, 20)
    }
}

#Preview {
    CapsuleRowPreview()
        .previewEnvironment()
}
#endif
