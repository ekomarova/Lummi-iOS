//
//  Required Notice: Copyright Evseniia Komarova (https://github.com/ekomarova)
//
//  Licensed under the PolyForm Noncommercial License 1.0.0.
//  See the LICENSE file in the repository root for full terms.
//  <https://polyformproject.org/licenses/noncommercial/1.0.0>
//

import SwiftUI
import SwiftData

// All Joys screen, opened from the Insights screen: a "Month" tab listing this month's joys, and an "All Time" tab
// listing every calendar year on record, each opening its own `YearJoysView` page — mirroring Trends.
struct AllJoysView: View {
    // Opens a year's page on the Insights tab's stack.
    let onOpenYear: (Int) -> Void

    // One single-entry fetch of the oldest joy: it gives the year list and tells whether the journal is empty.
    @Query(JoyEntry.oldestEntryDescriptor) private var oldestEntries: [JoyEntry]
    @State private var selectedTab: PeriodTab = .month

    private var availableYears: [Int] {
        TrendsCalculator.availableYears(oldestEntryDate: oldestEntries.first?.date)
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 30) {
                PeriodTabPicker(selection: $selectedTab)
                    .padding(.horizontal, 10)

                switch selectedTab {
                case .month:
                    // The calendar year is unused by `.month`, which always covers the current calendar month.
                    JoysListView(range: .month, year: Calendar.current.component(.year, from: Date()))
                case .allTime:
                    if oldestEntries.isEmpty {
                        NoEntriesView()
                    } else {
                        YearsListView(years: availableYears, accessibilityIDPrefix: "AllJoysYearRow", onSelect: onOpenYear)
                            .padding(.horizontal, 10)
                    }
                }
            }
            .padding(.top, 13)
            .padding(.bottom, 30)
        }
        .ignoresSafeArea(.container, edges: .bottom)
        .lummiNavigationTitle("All joys")
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
