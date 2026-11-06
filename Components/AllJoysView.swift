//
//  Required Notice: Copyright Evseniia Komarova (https://github.com/ekomarova)
//
//  Licensed under the PolyForm Noncommercial License 1.0.0.
//  See the LICENSE file in the repository root for full terms.
//  <https://polyformproject.org/licenses/noncommercial/1.0.0>
//

import SwiftUI

// All Joys screen, opened from the Insights screen: a "Month" tab listing this month's joys, and an "All Time" tab
// listing every calendar year on record, each opening its own `YearJoysView` page — mirroring Trends.
struct AllJoysView: View {
    // Opens a year's page on the Insights tab's stack.
    let onOpenYear: (Int) -> Void

    @State private var selectedTab: PeriodTab = .month

    var body: some View {
        PushedScrollPage(title: "All joys", top: PageSpacing.topBelowControl) {
            VStack(alignment: .leading, spacing: 30) {
                PeriodTabPicker(selection: $selectedTab)
                    .padding(.horizontal, 20)

                switch selectedTab {
                case .month:
                    JoysListView(range: .month)
                case .allTime:
                    YearsListSection(accessibilityIDPrefix: "AllJoysYearRow", onOpenYear: onOpenYear)
                }
            }
        }
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        AllJoysView(onOpenYear: { _ in })
    }
    .previewEnvironment()
}
#endif
