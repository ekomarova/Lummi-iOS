//
//  Copyright (c) 2026, Evseniia Komarova.
//  All rights reserved.
//
//  Licensed under the PolyForm Noncommercial License 1.0.0.
//  See the LICENSE file in the repository root for full terms.
//  <https://polyformproject.org/licenses/noncommercial/1.0.0>
//

import SwiftUI

extension View {
    // Applies the native Liquid Glass material on iOS 26+, falling back to
    // `.ultraThinMaterial` on earlier versions.
    @ViewBuilder
    func adaptiveGlass<S: Shape>(in shape: S, interactive: Bool = true) -> some View {
        if #available(iOS 26, *) {
            self.glassEffect(interactive ? .clear.interactive() : .clear, in: shape)
        } else {
            self
                .background(.ultraThinMaterial)
                .clipShape(shape)
        }
    }

    // Applies the shared "card" look: a subtle themed fill plus a matching stroke,
    // used for settings rows and capsule rows across the app.
    func cardBackground<S: Shape>(
        _ shape: S,
        fillOpacity: Double = CardOpacity.fill,
        strokeOpacity: Double = CardOpacity.stroke,
        lineWidth: CGFloat = 1
    ) -> some View {
        modifier(CardBackgroundModifier(shape: shape, fillOpacity: fillOpacity, strokeOpacity: strokeOpacity, lineWidth: lineWidth))
    }
}

// Backs `cardBackground`; kept private since call sites only need the `View` extension.
private struct CardBackgroundModifier<S: Shape>: ViewModifier {
    @Environment(ThemeManager.self) private var themeManager

    // The shape drawn for both the fill and the stroke, e.g. `RoundedRectangle` or `Capsule`.
    let shape: S
    // Opacity of `textColor` used for the background fill.
    let fillOpacity: Double
    // Opacity of `textColor` used for the border stroke.
    let strokeOpacity: Double
    // Stroke width, matching the 1pt hairline used everywhere this modifier replaced.
    let lineWidth: CGFloat

    func body(content: Content) -> some View {
        content
            .background(shape.fill(themeManager.currentTheme.textColor.opacity(fillOpacity)))
            .overlay(shape.stroke(themeManager.currentTheme.textColor.opacity(strokeOpacity), lineWidth: lineWidth))
    }
}

#if DEBUG
private struct CardBackgroundPreview: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("Rounded")
                .padding()
                .cardBackground(RoundedRectangle(cornerRadius: 20))

            Text("Capsule")
                .padding()
                .cardBackground(Capsule())
        }
        .padding()
    }
}

#Preview("Light") {
    CardBackgroundPreview()
        .previewEnvironment(isDark: false)
}

#Preview("Dark") {
    CardBackgroundPreview()
        .previewEnvironment(isDark: true)
}
#endif
