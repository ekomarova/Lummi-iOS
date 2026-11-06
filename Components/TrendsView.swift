//
//  Required Notice: Copyright Evseniia Komarova (https://github.com/ekomarova)
//
//  Licensed under the PolyForm Noncommercial License 1.0.0.
//  See the LICENSE file in the repository root for full terms.
//  <https://polyformproject.org/licenses/noncommercial/1.0.0>
//

import SwiftUI

// Trends screen: every calendar year on record, each opening its own `YearTrendsView` page —
// mirroring how Insights opens "All Joys". The current month's numbers live on Insights itself.
struct TrendsView: View {
    // Opens a year's page on the Insights tab's stack.
    let onOpenYear: (Int) -> Void

    var body: some View {
        PushedScrollPage(title: "Trends", top: PageSpacing.topBelowList) {
            YearsListSection(accessibilityIDPrefix: "TrendsYearRow", onOpenYear: onOpenYear)
        }
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        TrendsView(onOpenYear: { _ in })
    }
    .previewEnvironment()
}
#endif
