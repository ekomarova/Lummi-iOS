//
//  Required Notice: Copyright Evseniia Komarova (https://github.com/ekomarova)
//
//  Licensed under the PolyForm Noncommercial License 1.0.0.
//  See the LICENSE file in the repository root for full terms.
//  <https://polyformproject.org/licenses/noncommercial/1.0.0>
//

import SwiftUI

// Shared SwiftUI view modifiers: adaptive glass material and the themed card background.
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

    // For a scroll view with a lazy stack under a `scrollHeaderBackground` title. A lazy stack only keeps what is inside the
    // scroll view's frame, so content scrolled above the frame's edge is dropped, even with `.scrollClipDisabled()`.
    // This raises the frame by `extent` and pushes the content back down by the same amount, so nothing moves at rest
    // and the content stays alive all the way up to the top of the screen.
    func scrollsUnderHeader(extent: CGFloat = 200) -> some View {
        contentMargins(.top, extent, for: .scrollContent)
            .padding(.top, -extent)
    }

    // Marks a page title as the protected zone above a scrolling page. It gets a slightly transparent background in the
    // theme's color that reaches the top of the screen and ends in a sharp line `extraHeight` below the title, and it is
    // drawn above the page's content. Pair it with `.scrollClipDisabled()` on the scroll view, so the content keeps
    // scrolling up under the zone and shows through it faintly instead of being cut off at the scroll view's edge.
    func scrollHeaderBackground(alignment: Alignment = .center, extraHeight: CGFloat = 12) -> some View {
        modifier(ScrollHeaderBackgroundModifier(alignment: alignment, extraHeight: extraHeight))
    }

    // Applies the solid card look: an opaque fill in the theme's card color, with no stroke and no glass.
    func solidCard<S: Shape>(_ shape: S) -> some View {
        modifier(SolidCardModifier(shape: shape))
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

// Backs `scrollHeaderBackground`.
private struct ScrollHeaderBackgroundModifier: ViewModifier {
    @Environment(ThemeManager.self) private var themeManager

    let alignment: Alignment
    let extraHeight: CGFloat

    // Share of the background that stays opaque; the rest lets the content under the zone show through.
    private let opacity = 0.85

    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, alignment: alignment)
            // The gap under the status bar that `tabPage` used to add, now inside the zone so the zone reaches the screen top.
            .padding(.top, 8)
            .padding(.bottom, extraHeight)
            .background(themeManager.currentTheme.backgroundColor.opacity(opacity).ignoresSafeArea(edges: .top))
            .zIndex(1)
    }
}

// Backs `solidCard`.
private struct SolidCardModifier<S: Shape>: ViewModifier {
    @Environment(ThemeManager.self) private var themeManager

    let shape: S

    func body(content: Content) -> some View {
        content.background(shape.fill(themeManager.currentTheme.cardColor))
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
