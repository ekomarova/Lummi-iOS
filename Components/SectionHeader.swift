//
//  Required Notice: Copyright Evseniia Komarova (https://github.com/ekomarova)
//
//  Licensed under the PolyForm Noncommercial License 1.0.0.
//  See the LICENSE file in the repository root for full terms.
//  <https://polyformproject.org/licenses/noncommercial/1.0.0>
//

import SwiftUI

// Bold title above a group of cards or rows, e.g. "Highlights"/"Recall"/"Trends" on Insights.
struct SectionHeader: View {
    @Environment(ThemeManager.self) private var themeManager
    let title: LocalizedStringResource

    var body: some View {
        Text(title)
            .font(.lummiFont(size: 22, weight: .bold))
            .foregroundColor(themeManager.currentTheme.textColor)
    }
}

#if DEBUG
#Preview {
    SectionHeader(title: "Highlights")
        .previewEnvironment()
}
#endif
