//
//  Copyright (c) 2026, Evseniia Komarova.
//  All rights reserved.
//
//  Licensed under the PolyForm Noncommercial License 1.0.0.
//  See the LICENSE file in the repository root for full terms.
//  <https://polyformproject.org/licenses/noncommercial/1.0.0>
//

import SwiftUI

// Styled bubble for displaying and editing an already saved note; not used for the new-note input screen
struct NoteBubble<Content: View>: View {
    var strokeOpacity: Double = 0.25
    var lineWidth: CGFloat = 1
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(strokeOpacity), lineWidth: lineWidth)
            )
    }
}

#if DEBUG
private struct NoteBubblePreview: View {
    @Environment(ThemeManager.self) private var themeManager

    var body: some View {
        VStack(spacing: 15) {
            NoteBubble {
                Text("A quiet walk in the park.")
                    .font(.lummiFont(size: 17))
                    .foregroundColor(themeManager.currentTheme.textColor)
            }
            NoteBubble(strokeOpacity: 0.5, lineWidth: 2) {
                Text("Highlighted while active.")
                    .font(.lummiFont(size: 17))
                    .foregroundColor(themeManager.currentTheme.textColor)
            }
        }
        .padding()
    }
}

#Preview {
    NoteBubblePreview()
        .previewEnvironment()
}
#endif
