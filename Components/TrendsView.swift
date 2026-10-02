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

// Trends screen: a "Month" tab with this month's charts, and an "All Time" tab listing every calendar
// year on record, each opening its own `YearTrendsView` page — mirroring how Insights opens "All Joys".
struct TrendsView: View {
    @Environment(ThemeManager.self) private var themeManager
    @Binding var isShowingTrends: Bool

    // Two single-entry fetches instead of every entry: the oldest one gives the year list (and tells whether
    // the journal is empty), and any one entry of this month tells whether the Month tab has anything to chart.
    @Query(JoyEntry.oldestEntryDescriptor) private var oldestEntries: [JoyEntry]
    @Query private var entriesThisMonth: [JoyEntry]
    @State private var selectedTab: TrendsTab = .month
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
                    tabPicker

                    switch selectedTab {
                    case .month:
                        if hasEntriesThisMonth {
                            // `year` is unused by `.month`, which always covers the current calendar month.
                            TrendsChartsView(range: .month, year: Calendar.current.component(.year, from: Date()))
                        } else {
                            noEntriesView
                        }
                    case .allTime:
                        if oldestEntries.isEmpty {
                            noEntriesView
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

    // MARK: - Tab Picker

    private var tabPicker: some View {
        HStack(spacing: 4) {
            tabPill(title: "Month", isSelected: selectedTab == .month, action: { selectedTab = .month })
            tabPill(title: "All Time", isSelected: selectedTab == .allTime, action: { selectedTab = .allTime })
        }
        .padding(4)
        .cardBackground(Capsule())
    }

    private func tabPill(title: LocalizedStringResource, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.lummiFont(size: 13, weight: isSelected ? .bold : .regular))
                .foregroundColor(themeManager.currentTheme.textColor.opacity(isSelected ? 1 : 0.5))
                .minimumScaleFactor(0.8)
                .lineLimit(1)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(Capsule().fill(themeManager.currentTheme.textColor.opacity(isSelected ? CardOpacity.fill * 3 : 0)))
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }

    // Shown in place of either tab's content when the journal has no entries at all yet, matching
    // `SelectedDayDetailView`'s "No records for this day" placeholder.
    private var noEntriesView: some View {
        Text("Add at least one joy to see trends")
            .font(.lummiFont(size: 16))
            .foregroundColor(themeManager.currentTheme.textColor.opacity(0.3))
            .frame(maxWidth: .infinity)
            .padding(.top, 40)
    }

    // MARK: - Year List

    private var yearsList: some View {
        VStack(spacing: 12) {
            ForEach(availableYears, id: \.self) { year in
                DisclosureRow(
                    systemImage: "calendar",
                    iconColor: AccentColors.yearRow,
                    title: LocalizedStringKey(String(year)),
                    accessibilityID: "TrendsYearRow_\(year)"
                ) {
                    presentYear(year)
                }
            }
        }
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

// The two top-level Trends tabs. Kept separate from `TrendsRange` (the chart calculator's own
// month-vs-year granularity), since picking "All Time" opens a year list rather than a chart directly.
private enum TrendsTab: Equatable {
    case month
    case allTime
}

#if DEBUG
#Preview {
    TrendsView(isShowingTrends: .constant(true))
        .previewEnvironment()
}
#endif
