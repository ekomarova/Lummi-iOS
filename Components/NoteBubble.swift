//
//  Required Notice: Copyright Evseniia Komarova (https://github.com/ekomarova)
//
//  Licensed under the PolyForm Noncommercial License 1.0.0.
//  See the LICENSE file in the repository root for full terms.
//  <https://polyformproject.org/licenses/noncommercial/1.0.0>
//

import SwiftUI

// Styled bubble for displaying and editing an already saved note; not used for the new-note input screen.
// With a `sharpCorner` that corner is nearly square, like the tail of a speech bubble. The bubble is as wide as its
// content, like in a messenger: it sits on the trailing side for a trailing corner and on the leading side otherwise.
// `fillsWidth` stretches it across the row, for a text field that has no width of its own. The `.card` style is the
// quiet look of a card in the theme's colors, for a message from the app rather than an entry of the user.
struct NoteBubble<Content: View>: View {
    enum Style {
        case accent
        case card
    }

    @Environment(ThemeManager.self) private var themeManager

    var sharpCorner: NoteBubbleShape.Corner?
    var style = Style.accent
    var fillsWidth = false
    @ViewBuilder var content: () -> Content

    var body: some View {
        let shape = NoteBubbleShape.make(sharpCorner: sharpCorner)
        let textColor = themeManager.currentTheme.textColor
        content()
            .foregroundColor(textColor)
            // The text cursor of an edited note, which would otherwise take the page's text color.
            .tint(textColor)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(maxWidth: fillsWidth ? .infinity : nil, alignment: .leading)
            .background(shape.fill(style == .card ? themeManager.currentTheme.cardColor : themeManager.currentTheme.bubbleColor))
            // The tap area is the bubble itself, not the empty space beside it.
            .contentShape(shape)
            .frame(maxWidth: .infinity, alignment: sharpCorner == .bottomTrailing ? .trailing : .leading)
    }
}

// The bubble's outline. Kept out of the generic `NoteBubble`, which cannot hold static stored properties.
enum NoteBubbleShape {
    // Leading/trailing, so the corner follows the layout direction.
    enum Corner {
        case topLeading
        case bottomLeading
        case bottomTrailing
    }

    static let cornerRadius: CGFloat = 20
    static let sharpCornerRadius: CGFloat = 4

    static func make(sharpCorner: Corner?) -> UnevenRoundedRectangle {
        UnevenRoundedRectangle(
            topLeadingRadius: sharpCorner == .topLeading ? sharpCornerRadius : cornerRadius,
            bottomLeadingRadius: sharpCorner == .bottomLeading ? sharpCornerRadius : cornerRadius,
            bottomTrailingRadius: sharpCorner == .bottomTrailing ? sharpCornerRadius : cornerRadius,
            topTrailingRadius: cornerRadius
        )
    }
}

#if DEBUG
private struct NoteBubblePreview: View {
    var body: some View {
        VStack(spacing: 15) {
            NoteBubble(sharpCorner: .bottomLeading, style: .card) {
                Text("What made this day brighter?")
                    .lummiScaledFont(size: 17, relativeTo: .body)
            }
            NoteBubble(sharpCorner: .topLeading) {
                Text("A quiet walk in the park.")
                    .lummiScaledFont(size: 17, relativeTo: .body)
            }
            NoteBubble(sharpCorner: .bottomTrailing) {
                Text("A longer joy that still wraps onto a second line when it does not fit the width of the screen.")
                    .lummiScaledFont(size: 17, relativeTo: .body)
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
