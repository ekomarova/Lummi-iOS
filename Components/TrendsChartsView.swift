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

// Summary cards plus the "Joys By Date"/"Joys By Month" and "Joys By Weekday" charts for one range/year.
// Shared by `TrendsView`'s "Month" mode and `YearTrendsView`'s single-year page, so both stay pixel-identical.
struct TrendsChartsView: View {
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.locale) var locale

    // Only the entries of `range`, fetched by the store instead of filtered from the whole journal.
    @Query private var rangedEntries: [JoyEntry]

    let range: TrendsRange
    // Ignored for `.month`, which always covers the current calendar month.
    let year: Int
    // Taken once, so the fetched window and the calculation always agree on which month it is, even if the screen
    // stays open across a month change (it then keeps showing the month it was opened for, like Insights).
    private let now: Date

    init(range: TrendsRange, year: Int) {
        let now = Date()
        self.range = range
        self.year = year
        self.now = now
        _rangedEntries = Query(
            filter: JoyEntry.predicate(in: TrendsCalculator.dateRange(for: range, year: year, now: now)),
            sort: \JoyEntry.date
        )
    }

    private var stats: TrendsPerformanceStats {
        TrendsPerformanceStats.make(from: rangedEntries, range: range, year: year, locale: locale, now: now)
    }

    var body: some View {
        let stats = stats
        // Side by side on iPad, where two full-width charts would be needlessly wide and tall.
        let chartsLayout = AdaptiveLayout.isPad
            ? AnyLayout(HStackLayout(alignment: .top, spacing: 20))
            : AnyLayout(VStackLayout(alignment: .leading, spacing: 30))
        return VStack(alignment: .leading, spacing: 30) {
            summarySection(stats)

            chartsLayout {
                TrendsSection(title: volumeChartTitle) {
                    volumeChart(stats)
                }

                TrendsSection(title: "Joys By Weekday") {
                    weekdayChart(stats)
                }
            }
        }
    }

    // "Joys By Date" (day granularity) for `.month`, "Joys By Month" (month granularity) for `.year`.
    private var volumeChartTitle: LocalizedStringResource {
        range == .month ? "Joys By Date" : "Joys By Month"
    }

    // MARK: - Summary

    // iPad is wide enough for all four cards in one row; on iPhone the Joyful Hours card gets a row of its own.
    // It is only present on a year's page, not Trends' own Month tab: the main Insights screen already shows
    // this same card for the current month, so repeating it there would be redundant.
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
        GlowCard.joys(value: "\(stats.entryCount)", height: 130, valueFontSize: 26, valuePadding: 8)
        GlowCard(
            value: "\(stats.daysJournaled)",
            subtitle: "Active Days",
            systemImage: "calendar",
            iconColor: AccentColors.activeDays,
            gradientColors: AccentColors.activeDaysGradient,
            height: 130,
            valueFontSize: 26,
            valuePadding: 8
        )
        GlowCard.streak(value: "\(stats.bestStreak)", height: 130, valueFontSize: 26, valuePadding: 8)
    }

    // Full-width on iPhone, since the "HH:mm - HH:mm" value is wider than a short number and doesn't fit the
    // three-across row above; a quarter of the row on iPad, hence the smaller padding. `valueFontSize` still
    // matches the other cards for a consistent look.
    @ViewBuilder
    private func joyfulHoursCard(_ stats: TrendsPerformanceStats) -> some View {
        if let joyfulHours = stats.joyfulHours {
            GlowCard.joyfulHours(
                value: joyfulHours,
                height: 130,
                valueFontSize: 26,
                valuePadding: AdaptiveLayout.isPad ? 12 : 30
            )
        }
    }

    // MARK: - Charts

    private func volumeChart(_ stats: TrendsPerformanceStats) -> some View {
        Chart(stats.dataPoints) { point in
            BarMark(
                x: .value("Period", point.periodStart, unit: range.component),
                y: .value("Joys", point.count)
            )
            .foregroundStyle(trendsGradient)
            .cornerRadius(3)
        }
        .chartXAxis {
            // `.stride` places one tick per actual bar (each calendar day or month), unlike `.automatic`,
            // which interpolates evenly spaced ticks across the continuous date range and can land more
            // than one tick inside the same bar, duplicating its label (e.g. two ticks reading "Aug").
            AxisMarks(values: .stride(by: range.component, count: range == .month ? 4 : 1)) { value in
                AxisValueLabel {
                    if let date = value.as(Date.self) {
                        Text(volumeAxisLabel(for: date))
                            .font(.lummiFont(size: 10))
                            .foregroundColor(themeManager.currentTheme.textColor.opacity(0.5))
                    }
                }
            }
        }
        .chartYAxis { yAxisMarks }
        .frame(height: 160)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(volumeChartTitle))
        .accessibilityValue(Text("\(stats.entryCount)"))
    }

    private func weekdayChart(_ stats: TrendsPerformanceStats) -> some View {
        // `shortWeekdaySymbols` (e.g. "Tue", "Thu"), not `veryShortWeekdaySymbols`: the single-letter form
        // repeats a letter for two weekdays in English ("T" for Tuesday and Thursday, "S" for Saturday and
        // Sunday) and German, and a bar chart's x-axis is categorical by that string, so the second weekday
        // silently lands on top of the first bar instead of getting its own.
        let symbols = Calendar.lummiCalendar(locale: locale).shortWeekdaySymbols
        return Chart(stats.weekdayCounts) { item in
            BarMark(
                x: .value("Weekday", symbols[item.weekday - 1]),
                y: .value("Joys", item.count)
            )
            .foregroundStyle(weekdayGradient)
            .cornerRadius(3)
        }
        .chartXAxis {
            AxisMarks { value in
                AxisValueLabel {
                    if let label = value.as(String.self) {
                        Text(label)
                            .font(.lummiFont(size: 11))
                            .foregroundColor(themeManager.currentTheme.textColor.opacity(0.5))
                    }
                }
            }
        }
        .chartYAxis { yAxisMarks }
        // Matches the volume chart's height on iPad, so the two side-by-side cards line up.
        .frame(height: AdaptiveLayout.isPad ? 160 : 140)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("Joys By Weekday"))
    }

    // The volume chart's x-axis label: a bare day number within `.month`, or an explicitly localized,
    // capitalized three-letter month abbreviation otherwise. Built by hand rather than via
    // `AxisValueLabel(format:)` because Swift Charts' axis formatting does not reliably follow the app's
    // in-app language selection from the environment, and because Foundation lowercases standalone month
    // names in locales like Russian ("сент."), unlike English ("Sep") — `capitalizedFirstLetter` matches
    // `Date.monthYearTitle`. Some locales' abbreviated forms also carry a trailing period and run longer
    // than three letters (Russian's "нояб." vs. English's "Nov"); dropping the period and clipping to
    // three letters keeps every month label the same width so none crowd or overlap their neighbors.
    private func volumeAxisLabel(for date: Date) -> String {
        if range == .month {
            return date.formatted(Date.FormatStyle(locale: locale).day())
        }
        let month = date.formatted(Date.FormatStyle(locale: locale).month(.abbreviated))
        return String(month.replacingOccurrences(of: ".", with: "").prefix(3)).capitalizedFirstLetter
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
                    Text("\(count)")
                        .font(.lummiFont(size: 10))
                        .foregroundColor(themeManager.currentTheme.textColor.opacity(0.5))
                }
            }
        }
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

// Section title above a chart, matching Insights' "Highlights"/"Recall" section headers.
struct TrendsSection<Content: View>: View {
    @Environment(ThemeManager.self) private var themeManager
    let title: LocalizedStringResource
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.lummiFont(size: 18, weight: .bold))
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
        TrendsChartsView(range: .month, year: Calendar.current.component(.year, from: Date()))
            .padding(20)
    }
    .previewEnvironment()
}
#endif
