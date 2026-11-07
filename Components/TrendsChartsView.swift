//
//  Required Notice: Copyright Evseniia Komarova (https://github.com/ekomarova)
//
//  Licensed under the PolyForm Noncommercial License 1.0.0.
//  See the LICENSE file in the repository root for full terms.
//  <https://polyformproject.org/licenses/noncommercial/1.0.0>
//

import SwiftUI
import SwiftData
import Charts
import OSLog

// Summary cards plus the "Joys By Month" and "Joys By Weekday" charts for one calendar year.
// Used by `YearTrendsView`'s single-year page.
struct TrendsChartsView: View {
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.locale) var locale

    // Only the entries of `range`, fetched by the store instead of filtered from the whole journal.
    @Query private var rangedEntries: [JoyEntry]

    let year: Int
    // Taken once, so the fetched window and the calculation always agree on what "now" is, even if the screen
    // stays open across a year change.
    private let now: Date

    private static let barCornerRadius: CGFloat = 3
    private static let chartHeight: CGFloat = 160
    // Shorter than `chartHeight` on iPhone, where the weekday chart sits below the volume chart. On iPad the two charts
    // are side by side and share the height, so the cards line up.
    private static var weekdayChartHeight: CGFloat { AdaptiveLayout.isPad ? chartHeight : 140 }
    init(year: Int) {
        let now = Date()
        self.year = year
        self.now = now
        _rangedEntries = Query(
            filter: JoyEntry.predicate(in: TrendsCalculator.dateRange(for: .year(year), now: now)),
            sort: \JoyEntry.date
        )
    }

    #if DEBUG
    // Shows in Instruments (Points of Interest) how often the body runs and how often the statistics are really calculated.
    private static let signposter = OSSignposter(subsystem: "io.github.ekomarova.Lummi", category: .pointsOfInterest)
    #endif

    private func stats(calendar: Calendar) -> TrendsPerformanceStats {
        #if DEBUG
        let interval = Self.signposter.beginInterval("TrendsStats calculation")
        defer { Self.signposter.endInterval("TrendsStats calculation", interval) }
        #endif
        return TrendsPerformanceStats.make(from: rangedEntries, year: year, locale: locale, now: now, calendar: calendar)
    }

    var body: some View {
        #if DEBUG
        Self.signposter.emitEvent("TrendsChartsView body")
        #endif
        let calendar = Calendar.lummiCalendar(locale: locale)
        let stats = stats(calendar: calendar)
        // Side by side on iPad, where two full-width charts would be needlessly wide and tall.
        let chartsLayout = AdaptiveLayout.isPad
            ? AnyLayout(HStackLayout(alignment: .top, spacing: 20))
            : AnyLayout(VStackLayout(alignment: .leading, spacing: 30))
        return VStack(alignment: .leading, spacing: 30) {
            summarySection(stats)

            chartsLayout {
                TrendsSection(title: Self.volumeChartTitle) {
                    volumeChart(stats)
                }

                TrendsSection(title: "Joys By Weekday") {
                    weekdayChart(stats, calendar: calendar)
                }
            }
        }
    }

    private static let volumeChartTitle: LocalizedStringResource = "Joys By Month"

    // MARK: - Summary

    // iPad is wide enough for all four cards in one row; on iPhone the Joyful Hours card gets a row of its own.
    @ViewBuilder
    private func summarySection(_ stats: TrendsPerformanceStats) -> some View {
        if AdaptiveLayout.isPad {
            HStack(spacing: 12) {
                countCards(stats)
                joyfulHoursCard(stats)
            }
        } else {
            VStack(spacing: 15) {
                HStack(spacing: 12) {
                    countCards(stats)
                }
                joyfulHoursCard(stats)
            }
        }
    }

    @ViewBuilder
    private func countCards(_ stats: TrendsPerformanceStats) -> some View {
        GlowCard(kind: .joys, value: "\(stats.entryCount)", metrics: .trends)
        GlowCard(kind: .activeDays, value: "\(stats.daysJournaled)", metrics: .trends)
        GlowCard(kind: .streak, value: "\(stats.bestStreak)", metrics: .trends)
    }

    // Full-width on iPhone, since its value doesn't fit the three-across row above (see `Metrics.trendsJoyfulHours`).
    private func joyfulHoursCard(_ stats: TrendsPerformanceStats) -> some View {
        GlowCard(kind: .joyfulHours, value: stats.joyfulHours, metrics: .trendsJoyfulHours)
    }

    // MARK: - Charts

    private func volumeChart(_ stats: TrendsPerformanceStats) -> some View {
        Chart(stats.dataPoints) { point in
            BarMark(
                x: .value("Period", point.periodStart, unit: .month),
                y: .value("Joys", point.count)
            )
            .foregroundStyle(trendsGradient)
            .cornerRadius(Self.barCornerRadius)
        }
        .chartXAxis {
            // `.stride` places one tick per actual bar (each calendar month), unlike `.automatic`,
            // which interpolates evenly spaced ticks across the continuous date range and can land more
            // than one tick inside the same bar, duplicating its label (e.g. two ticks reading "Aug").
            AxisMarks(values: .stride(by: .month)) { value in
                AxisValueLabel {
                    if let date = value.as(Date.self) {
                        axisLabel(date.monthName(style: .threeLetters, locale: locale))
                    }
                }
            }
        }
        .chartYAxis { yAxisMarks }
        .frame(height: Self.chartHeight)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(Self.volumeChartTitle))
        .accessibilityValue(Text("\(stats.entryCount)"))
    }

    private func weekdayChart(_ stats: TrendsPerformanceStats, calendar: Calendar) -> some View {
        // `shortWeekdaySymbols` (e.g. "Tue", "Thu"), not `veryShortWeekdaySymbols`: the single-letter form
        // repeats a letter for two weekdays in English ("T" for Tuesday and Thursday, "S" for Saturday and
        // Sunday) and German, and a bar chart's x-axis is categorical by that string, so the second weekday
        // silently lands on top of the first bar instead of getting its own.
        let symbols = calendar.shortWeekdaySymbols
        return Chart(stats.weekdayCounts) { item in
            BarMark(
                x: .value("Weekday", symbols[item.weekday - 1]),
                y: .value("Joys", item.count)
            )
            .foregroundStyle(weekdayGradient)
            .cornerRadius(Self.barCornerRadius)
        }
        .chartXAxis {
            AxisMarks { value in
                AxisValueLabel {
                    if let label = value.as(String.self) {
                        axisLabel(label)
                    }
                }
            }
        }
        .chartYAxis { yAxisMarks }
        .frame(height: Self.weekdayChartHeight)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("Joys By Weekday"))
    }

    // A few faint gridlines with integer counts, so a bar's height reads as a number of joys rather than
    // being purely relative to its neighbors. Shared by both charts to keep the same restrained styling.
    @AxisContentBuilder
    private var yAxisMarks: some AxisContent {
        AxisMarks(position: .leading, values: .automatic(desiredCount: 3)) { value in
            AxisGridLine()
                .foregroundStyle(themeManager.currentTheme.textColor.opacity(0.08))
            AxisValueLabel {
                if let count = value.as(Int.self) {
                    axisLabel("\(count)")
                }
            }
        }
    }

    // A tick label on a chart axis: one size and color for every axis label of every chart. Built here and not as a
    // separate view, so it takes the theme from this view and not from the environment inside Swift Charts.
    private func axisLabel(_ text: String) -> some View {
        Text(text)
            .font(.lummiFont(size: 10))
            .foregroundColor(themeManager.currentTheme.secondaryTextColor)
    }

    private var trendsGradient: LinearGradient {
        LinearGradient(colors: AccentColors.trendsVolumeGradient, startPoint: .top, endPoint: .bottom)
    }

    // A distinct color for the weekday chart, so it doesn't read as a continuation of the volume chart above it.
    private var weekdayGradient: LinearGradient {
        LinearGradient(colors: AccentColors.weekdayGradient, startPoint: .top, endPoint: .bottom)
    }
}

// MARK: - UI Components

// Section title above a chart, matching Insights' "Recap"/"Trends" section headers.
struct TrendsSection<Content: View>: View {
    @Environment(ThemeManager.self) private var themeManager
    let title: LocalizedStringResource
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .lummiScaledFont(size: 18, weight: .bold, relativeTo: .body)
                .foregroundColor(themeManager.currentTheme.textColor)

            content()
                .padding(.vertical, 10)
                .padding(.horizontal, 12)
                .solidCard(RoundedRectangle(cornerRadius: 20))
        }
    }
}

#if DEBUG
#Preview {
    ScrollView {
        TrendsChartsView(year: Calendar.current.component(.year, from: Date()))
            .padding(20)
    }
    .previewEnvironment()
}

#Preview("Section") {
    TrendsSection(title: "Joys By Weekday") {
        Text("Chart")
            .frame(maxWidth: .infinity)
    }
    .padding(20)
    .previewEnvironment()
}
#endif
