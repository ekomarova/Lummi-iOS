//
//  Required Notice: Copyright Evseniia Komarova (https://github.com/ekomarova)
//
//  Licensed under the PolyForm Noncommercial License 1.0.0.
//  See the LICENSE file in the repository root for full terms.
//  <https://polyformproject.org/licenses/noncommercial/1.0.0>
//

import SwiftUI
import SwiftData

// Trends screen: a "Month" tab with this month's charts, and an "All Time" tab listing every calendar
// year on record, each opening its own `YearTrendsView` page — mirroring how Insights opens "All Joys".
struct TrendsView: View {
    @Binding var isShowingTrends: Bool

    // Two single-entry fetches instead of every entry: the oldest one gives the year list (and tells whether
    // the journal is empty), and any one entry of this month tells whether the Month tab has anything to chart.
    @Query(JoyEntry.oldestEntryDescriptor) private var oldestEntries: [JoyEntry]
    @Query private var entriesThisMonth: [JoyEntry]
    @State private var selectedTab: PeriodTab = .month
    @State private var openYear: Int?

    init(isShowingTrends: Binding<Bool>) {
        _isShowingTrends = isShowingTrends
        var thisMonth = FetchDescriptor<JoyEntry>(predicate: JoyEntry.monthPredicate(for: Date()))
        thisMonth.fetchLimit = 1
        _entriesThisMonth = Query(thisMonth)
    }

    private var oldestEntryDate: Date? { oldestEntries.first?.date }

    private var availableYears: [Int] {
        TrendsCalculator.availableYears(oldestEntryDate: oldestEntryDate)
    }

    // Month's own empty check is scoped to the current month, not the whole journal: an otherwise
    // active journal with a quiet month still has nothing to chart for "Joys By Date"/"Joys By Weekday".
    private var hasEntriesThisMonth: Bool {
        !entriesThisMonth.isEmpty
    }

    var body: some View {
        if let openYear {
            YearTrendsView(year: openYear, onBack: { closeYear() })
        } else {
            trendsContent
        }
    }

    private var trendsContent: some View {
        VStack(spacing: 0) {
            ScreenHeader(
                title: "Trends",
                leftButton: {
                    NavigationIconButton(systemImage: "arrow.left", accessibilityLabel: "Back", accessibilityID: "TrendsBackButton") {
                        withAnimation(.lummiSpring) {
                            isShowingTrends = false
                        }
                    }
                }
            )

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 30) {
                    PeriodTabPicker(selection: $selectedTab)

                    switch selectedTab {
                    case .month:
                        if hasEntriesThisMonth {
                            // `year` is unused by `.month`, which always covers the current calendar month.
                            TrendsChartsView(range: .month, year: Calendar.current.component(.year, from: Date()))
                        } else {
                            NoEntriesView()
                        }
                    case .allTime:
                        if oldestEntries.isEmpty {
                            NoEntriesView()
                        } else {
                            yearsList
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 25)
                .padding(.bottom, 30)
            }
            .ignoresSafeArea(.container, edges: .bottom)
        }
        .transition(.move(edge: .trailing).combined(with: .opacity))
    }

    // MARK: - Year List

    private var yearsList: some View {
        YearsListView(years: availableYears, accessibilityIDPrefix: "TrendsYearRow", onSelect: presentYear)
    }

    // MARK: - Navigation

    private func presentYear(_ year: Int) {
        withAnimation(.lummiSpring) {
            openYear = year
        }
    }

    private func closeYear() {
        withAnimation(.lummiSpring) {
            openYear = nil
        }
    }
}

#if DEBUG
#Preview {
    TrendsView(isShowingTrends: .constant(true))
        .previewEnvironment()
}
#endif
