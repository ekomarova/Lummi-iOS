//
//  Required Notice: Copyright Evseniia Komarova (https://github.com/ekomarova)
//
//  Licensed under the PolyForm Noncommercial License 1.0.0.
//  See the LICENSE file in the repository root for full terms.
//  <https://polyformproject.org/licenses/noncommercial/1.0.0>
//

import SwiftUI

// Large bold title at the top of a tab's root page (Home, Insights, Settings).
struct TabPageTitle: View {
    @Environment(ThemeManager.self) private var themeManager

    private let text: Text

    // A fixed, localized title such as "Insights".
    init(_ title: LocalizedStringResource) {
        text = Text(title)
    }

    // A title that is already final text, such as Home's date.
    init(verbatim title: String) {
        text = Text(verbatim: title)
    }

    var body: some View {
        text
            .lummiScaledFont(size: 28, weight: .bold, relativeTo: .largeTitle)
            .foregroundColor(themeManager.currentTheme.textColor)
            .accessibilityAddTraits(.isHeader)
            .padding(.top, 10)
            .padding(.horizontal, 20)
    }
}

#if DEBUG
#Preview {
    VStack(alignment: .leading) {
        TabPageTitle("Insights")
        TabPageTitle(verbatim: "7 November")
        Spacer()
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .previewEnvironment()
}
#endif
