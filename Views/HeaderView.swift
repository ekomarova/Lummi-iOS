//
//  Required Notice: Copyright Evseniia Komarova (https://github.com/ekomarova)
//
//  Licensed under the PolyForm Noncommercial License 1.0.0.
//  See the LICENSE file in the repository root for full terms.
//  <https://polyformproject.org/licenses/noncommercial/1.0.0>
//

import SwiftUI

// Title of Home: today's day and month, in the style of the Insights and Settings titles. Unlike them it changes
// with the date.
struct HeaderView: View {
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.locale) var locale

    let date: Date

    private var headerDateText: String {
        "\(date.format("d", locale: locale)) \(date.format("MMMM", locale: locale).capitalizedFirstLetter)"
    }

    var body: some View {
        Text(headerDateText)
            .lummiScaledFont(size: 32, weight: .bold, relativeTo: .largeTitle)
            .foregroundColor(themeManager.currentTheme.textColor)
            .accessibilityIdentifier("HeaderDateText")
            .accessibilityAddTraits(.isHeader)
            .padding(.top, 10)
            .padding(.horizontal, 20)
    }
}

#if DEBUG
#Preview {
    VStack(alignment: .leading, spacing: 15) {
        HeaderView(date: Date())
        Spacer()
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .previewEnvironment()
}
#endif
