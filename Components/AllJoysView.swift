//
//  Copyright (c) 2026, Evseniia Komarova.
//  All rights reserved.
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
    @Binding var isShowingAllJoys: Bool

    // One single-entry fetch of the oldest joy: it gives the year list and tells whether the journal is empty.
    @Query(JoyEntry.oldestEntryDescriptor) private var oldestEntries: [JoyEntry]
    @State private var selectedTab: PeriodTab = .month
    @State private var openYear: Int?

    private var availableYears: [Int] {
        TrendsCalculator.availableYears(oldestEntryDate: oldestEntries.first?.date)
    }

    var body: some View {
        if let openYear {
            YearJoysView(year: openYear, onBack: { closeYear() })
        } else {
            allJoysContent
        }
    }

    private var allJoysContent: some View {
        VStack(spacing: 0) {
            ScreenHeader(
                title: "All joys",
                leftButton: {
                    NavigationIconButton(systemImage: "arrow.left", accessibilityLabel: "Back", accessibilityID: "AllJoysBackButton") {
                        withAnimation(.lummiSpring) {
                            isShowingAllJoys = false
                        }
                    }
                }
            )

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
                            YearsListView(years: availableYears, accessibilityIDPrefix: "AllJoysYearRow", onSelect: presentYear)
                                .padding(.horizontal, 10)
                        }
                    }
                }
                .padding(.top, 25)
                .padding(.bottom, 30)
            }
            .ignoresSafeArea(.container, edges: .bottom)
        }
        .transition(.move(edge: .trailing).combined(with: .opacity))
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
    AllJoysView(isShowingAllJoys: .constant(true))
        .previewEnvironment()
}
#endif
