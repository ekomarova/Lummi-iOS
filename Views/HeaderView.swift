//
//  Required Notice: Copyright Evseniia Komarova (https://github.com/ekomarova)
//
//  Licensed under the PolyForm Noncommercial License 1.0.0.
//  See the LICENSE file in the repository root for full terms.
//  <https://polyformproject.org/licenses/noncommercial/1.0.0>
//

import SwiftUI

// Title of Home: the selected day and month, in the style of the Insights and Settings titles. Unlike them it changes
// with the date.
struct HeaderView: View {
    @Environment(\.locale) var locale

    let date: Date

    private var headerDateText: String {
        "\(date.format("d", locale: locale)) \(date.monthName(style: .full, locale: locale))"
    }

    var body: some View {
        TabPageTitle(verbatim: headerDateText)
            .accessibilityIdentifier("HeaderDateText")
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
