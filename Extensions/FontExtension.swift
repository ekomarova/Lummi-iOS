//
//  Required Notice: Copyright Evseniia Komarova (https://github.com/ekomarova)
//
//  Licensed under the PolyForm Noncommercial License 1.0.0.
//  See the LICENSE file in the repository root for full terms.
//  <https://polyformproject.org/licenses/noncommercial/1.0.0>
//

import SwiftUI

// Device-idiom check and the app's shared font builder.
enum AdaptiveLayout {
    static var isPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
}

extension DynamicTypeSize {
    // The text sizes the app lays out for: every step of the system slider up to the second accessibility size.
    // Larger sizes would break the fixed-height cards and buttons, so the root view caps the setting here.
    static let lummiSupportedRange: ClosedRange<DynamicTypeSize> = .xSmall ... .accessibility2
}

// Scales the font with the text size the user picked in Settings. `size` is the point size at the default
// "Large" setting, and `style` is the Dynamic Type text style whose scaling curve it follows.
// Used only for joy entries, titles and menu names. Charts and cards keep a fixed size with `Font.lummiFont`.
private struct LummiFontModifier: ViewModifier {
    @ScaledMetric private var scaledSize: CGFloat
    private let weight: Font.Weight

    init(size: CGFloat, weight: Font.Weight, relativeTo style: Font.TextStyle) {
        _scaledSize = ScaledMetric(wrappedValue: size, relativeTo: style)
        self.weight = weight
    }

    func body(content: Content) -> some View {
        content.font(.system(size: scaledSize, weight: weight, design: .default))
    }
}

extension View {
    func lummiScaledFont(size: CGFloat, weight: Font.Weight = .regular, relativeTo style: Font.TextStyle) -> some View {
        modifier(LummiFontModifier(size: size, weight: weight, relativeTo: style))
    }
}

extension Font {
    // Fixed size that ignores the user's text size. For charts and cards, which are laid out for one size.
    static func lummiFont(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        return .system(size: size, weight: weight, design: .default)
    }
}
