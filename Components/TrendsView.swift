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

    @Query(sort: \JoyEntry.date) private var allEntries: [JoyEntry]
    @State private var selectedTab: TrendsTab = .month
    @State private var openYear: Int?

    private var oldestEntryDate: Date? { allEntries.first?.date }

    private var availableYears: [Int] {
        TrendsCalculator.availableYears(oldestEntryDate: oldestEntryDate)
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
                    NavigationIconButton(systemImage: "arrow.left", accessibilityID: "TrendsBackButton") {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
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
                        // `year` is unused by `.month`, which always covers the current calendar month.
                        TrendsChartsView(range: .month, year: Calendar.current.component(.year, from: Date()))
                    case .allTime:
                        yearsList
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

    // MARK: - Year List

    private var yearsList: some View {
        VStack(spacing: 12) {
            ForEach(availableYears, id: \.self) { year in
                Button(
                    action: { presentYear(year) },
                    label: {
                        CapsuleRow {
                            HStack(spacing: 10) {
                                Image(systemName: "calendar")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(Color(red: 0.45, green: 0.25, blue: 0.75))

                                Text(String(year))
                                    .font(.lummiFont(size: 17))
                                    .foregroundColor(themeManager.currentTheme.textColor)

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(themeManager.currentTheme.textColor.opacity(0.6))
                            }
                        }
                    }
                )
                .buttonStyle(.plain)
                .accessibilityIdentifier("TrendsYearRow_\(year)")
            }
        }
    }

    // MARK: - Navigation

    private func presentYear(_ year: Int) {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
            openYear = year
        }
    }

    private func closeYear() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
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
