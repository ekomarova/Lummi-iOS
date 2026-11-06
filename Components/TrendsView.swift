//
//  Required Notice: Copyright Evseniia Komarova (https://github.com/ekomarova)
//
//  Licensed under the PolyForm Noncommercial License 1.0.0.
//  See the LICENSE file in the repository root for full terms.
//  <https://polyformproject.org/licenses/noncommercial/1.0.0>
//

import SwiftUI
import SwiftData

// Trends screen: every calendar year on record, each opening its own `YearTrendsView` page —
// mirroring how Insights opens "All Joys". The current month's numbers live on Insights itself.
struct TrendsView: View {
    // Opens a year's page on the Insights tab's stack.
    let onOpenYear: (Int) -> Void

    // A single-entry fetch instead of every entry: the oldest one gives the year list and tells whether
    // the journal is empty.
    @Query(JoyEntry.oldestEntryDescriptor) private var oldestEntries: [JoyEntry]

    private var availableYears: [Int] {
        TrendsCalculator.availableYears(oldestEntryDate: oldestEntries.first?.date)
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 30) {
                if oldestEntries.isEmpty {
                    NoEntriesView()
                } else {
                    YearsListView(years: availableYears, accessibilityIDPrefix: "TrendsYearRow", onSelect: onOpenYear)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, PageSpacing.topBelowList)
            .padding(.bottom, 30)
        }
        .ignoresSafeArea(.container, edges: .bottom)
        .lummiNavigationTitle("Trends")
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
