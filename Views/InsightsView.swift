//
//  Required Notice: Copyright Evseniia Komarova (https://github.com/ekomarova)
//
//  Licensed under the PolyForm Noncommercial License 1.0.0.
//  See the LICENSE file in the repository root for full terms.
//  <https://polyformproject.org/licenses/noncommercial/1.0.0>
//

import SwiftUI
import SwiftData

// Insights screen: stats and a report for the current month.
// The child view below fetches only that month's entries.
struct InsightsView: View {
    // Opens a page on the Insights tab's stack.
    let onNavigate: (Route) -> Void

    var body: some View {
        InsightsMonthView(month: Date().startOfMonth, onNavigate: onNavigate)
    }
}

// Stats and entries of the given month. The query is rebuilt whenever the parent passes a new month.
private struct InsightsMonthView: View {
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.locale) var locale
    let onNavigate: (Route) -> Void

    private static var highlightColumns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 15), count: AdaptiveLayout.isPad ? 4 : 2)
    }

    @Query private var monthlyEntries: [JoyEntry]

    init(month: Date, onNavigate: @escaping (Route) -> Void) {
        self.onNavigate = onNavigate
        _monthlyEntries = Query(filter: JoyEntry.monthPredicate(for: month), sort: \JoyEntry.date)
    }

    // MARK: - Body
    var body: some View {
        // The title's protected zone takes 12pt of the old 20pt gap (see `scrollHeaderBackground`).
        VStack(alignment: .leading, spacing: 8) {

            Text("Insights")
                .lummiScaledFont(size: 28, weight: .bold, relativeTo: .largeTitle)
                .foregroundColor(themeManager.currentTheme.textColor)
                .padding(.top, 10)
                .padding(.horizontal, 20)
                .scrollHeaderBackground(alignment: .leading)

            // MARK: - Main Content Area
            ScrollView(showsIndicators: false) {
                VStack(spacing: 35) {

                    // MARK: - Highlights
                    // Four cards in one row on iPad, two rows of two on iPhone.
                    LazyVGrid(columns: Self.highlightColumns, spacing: 15) {
                        joysCard
                        joyfulHoursCard
                        activeDaysCard
                        streakCard
                    }

                    // MARK: - Recap
                    VStack(alignment: .leading, spacing: 15) {
                        SectionHeader(title: "Recap")

                        DisclosureRow(
                            systemImage: "list.star",
                            iconColor: AccentColors.activeDays,
                            title: "Show All Joys",
                            accessibilityID: "SeeAllJoysButton"
                        ) {
                            onNavigate(.allJoys)
                        }
                    }

                    // MARK: - Trends
                    VStack(alignment: .leading, spacing: 15) {
                        SectionHeader(title: "Trends")

                        DisclosureRow(
                            systemImage: "chart.bar.fill",
                            iconColor: AccentColors.activeDays,
                            title: "View Trends",
                            accessibilityID: "ShowTrendsButton"
                        ) {
                            onNavigate(.trends)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 100)
            }
            .scrollClipDisabled()
            .ignoresSafeArea(.container, edges: .bottom)
        }
    }

    // MARK: - Highlight Cards

    private var joysCard: some View {
        GlowCard.joys(value: "\(monthlyEntries.count)", metrics: .insights)
    }

    private var activeDaysCard: some View {
        GlowCard.activeDays(value: "\(InsightsCalculator.uniqueDaysCount(in: monthlyEntries))", metrics: .insights)
    }

    private var streakCard: some View {
        GlowCard.streak(value: "\(InsightsCalculator.longestStreak(in: monthlyEntries))", metrics: .insights)
    }

    private var joyfulHoursCard: some View {
        GlowCard.joyfulHours(
            value: InsightsCalculator.joyfulHours(entries: monthlyEntries, locale: locale),
            metrics: .insights
        )
    }
}

#if DEBUG
#Preview {
    InsightsView(onNavigate: { _ in })
        .previewEnvironment()
}

#Preview("Largest text") {
    InsightsView(onNavigate: { _ in })
        .dynamicTypeSize(DynamicTypeSize.lummiSupportedRange.upperBound)
        .previewEnvironment()
}
#endif
