//
//  Copyright (c) 2026, Evseniia Komarova.
//  All rights reserved.
//
//  Licensed under the PolyForm Noncommercial License 1.0.0.
//  See the LICENSE file in the repository root for full terms.
//  <https://polyformproject.org/licenses/noncommercial/1.0.0>
//

import SwiftUI

// Bold title above a group of cards or rows, e.g. "Highlights"/"Recall"/"Trends" on Insights.
// `leadingInset` lines it up with content that sits in a padded scroll view.
struct SectionHeader: View {
    @Environment(ThemeManager.self) private var themeManager
    let title: LocalizedStringResource
    var leadingInset: CGFloat = 0

    var body: some View {
        Text(title)
            .font(.lummiFont(size: 20, weight: .bold))
            .foregroundColor(themeManager.currentTheme.textColor)
            .padding(.leading, leadingInset)
    }
}

#if DEBUG
#Preview {
    SectionHeader(title: "Highlights", leadingInset: 10)
        .previewEnvironment()
}
#endif
