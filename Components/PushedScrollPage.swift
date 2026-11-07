//
//  Required Notice: Copyright Evseniia Komarova (https://github.com/ekomarova)
//
//  Licensed under the PolyForm Noncommercial License 1.0.0.
//  See the LICENSE file in the repository root for full terms.
//  <https://polyformproject.org/licenses/noncommercial/1.0.0>
//

import SwiftUI

// Frame of a page pushed onto a tab's stack (All Joys, Trends, a year): a navigation title and scrolling content that
// runs under the tab bar. Horizontal padding is left to the content, because some pages pad only part of it.
struct PushedScrollPage<Content: View>: View {
    let title: LocalizedStringResource
    // Space above the content, from `PageSpacing`.
    let top: CGFloat
    @ViewBuilder let content: Content

    var body: some View {
        ScrollView(showsIndicators: false) {
            content
                .padding(.top, top)
                .padding(.bottom, 30)
        }
        .ignoresSafeArea(.container, edges: .bottom)
        .lummiNavigationTitle(title)
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        PushedScrollPage(title: "Trends", top: PageSpacing.topBelowList) {
            YearsListView(years: [2026, 2025], accessibilityIDPrefix: "PreviewYearRow", onSelect: { _ in })
                .padding(.horizontal, 20)
        }
    }
    .previewEnvironment()
}
#endif
