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
import Charts

// Summary cards plus the "Joys By Date"/"Joys By Month" and "Joys By Weekday" charts for one range/year.
// Shared by `TrendsView`'s "Month" mode and `YearTrendsView`'s single-year page, so both stay pixel-identical.
struct TrendsChartsView: View {
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.locale) var locale

    @Query(sort: \JoyEntry.date) private var allEntries: [JoyEntry]

    let range: TrendsRange
    // Ignored for `.month`, which always covers the current calendar month.
    let year: Int

    // Entries are sorted oldest-first, so the first one is the journal's very first entry.
    private var oldestEntryDate: Date? { allEntries.first?.date }

    private var rangedEntries: [JoyEntry] {
        TrendsCalculator.entries(allEntries, in: range, year: year, oldestEntryDate: oldestEntryDate)
    }

    private var dataPoints: [TrendsDataPoint] {
        TrendsCalculator.dataPoints(for: rangedEntries, range: range, year: year, oldestEntryDate: oldestEntryDate)
    }

    private var weekdayCounts: [WeekdayCount] {
        TrendsCalculator.weekdayCounts(in: rangedEntries, calendar: .lummiCalendar(locale: locale))
    }

    private var daysJournaled: Int { InsightsCalculator.uniqueDaysCount(in: rangedEntries) }
    private var bestStreak: Int { InsightsCalculator.longestStreak(in: rangedEntries) }
    private var joyfulHours: String { InsightsCalculator.calculateGoldenHours(entries: rangedEntries, locale: locale) }

    var body: some View {
        VStack(alignment: .leading, spacing: 30) {
            VStack(spacing: 15) {
                summaryCards
                // Only on a year's page, not Trends' own Month tab: the main Insights screen already
                // shows this same card for the current month, so repeating it there would be redundant.
                if range == .year {
                    joyfulHoursCard
                }
            }

            TrendsSection(title: volumeChartTitle) {
                volumeChart
            }

            TrendsSection(title: "Joys By Weekday") {
                weekdayChart
            }
        }
    }

    // "Joys By Date" (day granularity) for `.month`, "Joys By Month" (month granularity) for `.year`.
    private var volumeChartTitle: LocalizedStringResource {
        range == .month ? "Joys By Date" : "Joys By Month"
    }

    // MARK: - Summary

    private var summaryCards: some View {
        HStack(spacing: 12) {
            GlowCard(
                value: "\(rangedEntries.count)",
                subtitle: "Joys",
                systemImage: "star.fill",
                iconColor: Color(red: 1.0, green: 0.55, blue: 0.1),
                gradientColors: [Color(red: 1.0, green: 0.8, blue: 0.3), Color(red: 0.2, green: 0.6, blue: 0.3)],
                height: 130,
                valueFontSize: 26,
                valuePadding: 8
            )
            GlowCard(
                value: "\(daysJournaled)",
                subtitle: "Active Days",
                systemImage: "calendar",
                iconColor: Color(red: 0.3, green: 0.6, blue: 0.95),
                gradientColors: [Color(red: 0.5, green: 0.75, blue: 1.0), Color(red: 0.3, green: 0.4, blue: 0.85)],
                height: 130,
                valueFontSize: 26,
                valuePadding: 8
            )
            GlowCard(
                value: "\(bestStreak)",
                subtitle: "Day Streak",
                systemImage: "flame.fill",
                iconColor: Color(red: 0.95, green: 0.2, blue: 0.2),
                gradientColors: [Color(red: 1.0, green: 0.8, blue: 0.3), Color(red: 0.95, green: 0.4, blue: 0.1)],
                height: 130,
                valueFontSize: 26,
                valuePadding: 8
            )
        }
    }

    // Full-width, since the "HH:mm - HH:mm" value is wider than a short number and doesn't fit the
    // three-across row above. `valueFontSize` still matches those three cards for a consistent look.
    private var joyfulHoursCard: some View {
        GlowCard(
            value: joyfulHours,
            subtitle: "Joyful Hours",
            systemImage: "sun.max.fill",
            gradientColors: [Color(red: 0.6, green: 0.3, blue: 0.8), Color(red: 1.0, green: 0.8, blue: 0.3)],
            height: 130,
            valueFontSize: 26,
            valuePadding: 30
        )
    }

    // MARK: - Charts

    private var volumeChart: some View {
        Chart(dataPoints) { point in
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
            AxisMarks(values: .stride(by: range.component, count: range == .month ? 5 : 1)) { value in
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
        .accessibilityValue(Text("\(rangedEntries.count)"))
    }

    private var weekdayChart: some View {
        // `shortWeekdaySymbols` (e.g. "Tue", "Thu"), not `veryShortWeekdaySymbols`: the single-letter form
        // repeats a letter for two weekdays in English ("T" for Tuesday and Thursday, "S" for Saturday and
        // Sunday) and German, and a bar chart's x-axis is categorical by that string, so the second weekday
        // silently lands on top of the first bar instead of getting its own.
        let symbols = Calendar.lummiCalendar(locale: locale).shortWeekdaySymbols
        return Chart(weekdayCounts) { item in
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
        .frame(height: 140)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("Joys By Weekday"))
    }

    // The volume chart's x-axis label: a bare day number within `.month`, or an explicitly localized,
    // capitalized month abbreviation otherwise. Built by hand rather than via `AxisValueLabel(format:)`
    // because Swift Charts' axis formatting does not reliably follow the app's in-app language selection
    // from the environment, and because Foundation lowercases standalone month names in locales like
    // Russian ("сент."), unlike English ("Sep") — `capitalizedFirstLetter` matches `Date.monthYearTitle`.
    private func volumeAxisLabel(for date: Date) -> String {
        if range == .month {
            return date.formatted(Date.FormatStyle(locale: locale).day())
        }
        return date.formatted(Date.FormatStyle(locale: locale).month(.abbreviated)).capitalizedFirstLetter
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
        LinearGradient(
            colors: [Color(red: 0.75, green: 0.6, blue: 0.95), Color(red: 0.45, green: 0.25, blue: 0.75)],
            startPoint: .top, endPoint: .bottom
        )
    }

    // A distinct color for the weekday chart, so it doesn't read as a continuation of the volume chart above it.
    private var weekdayGradient: LinearGradient {
        LinearGradient(
            colors: [Color(red: 0.55, green: 0.85, blue: 0.55), Color(red: 0.15, green: 0.55, blue: 0.35)],
            startPoint: .top, endPoint: .bottom
        )
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
                .cardBackground(RoundedRectangle(cornerRadius: 20))
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
