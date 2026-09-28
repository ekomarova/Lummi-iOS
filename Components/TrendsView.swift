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

// Screen showing joy-writing trends across a selectable time range, opened from the Insights screen.
// Fetches every entry (unlike the month-scoped screens) since the widest range needs the full history.
struct TrendsView: View {
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.locale) var locale
    @Binding var isShowingTrends: Bool

    @Query(sort: \JoyEntry.date) private var allEntries: [JoyEntry]
    @State private var selectedRange: TrendsRange = .year

    private var oldestEntryDate: Date? { allEntries.first?.date }

    private var rangedEntries: [JoyEntry] {
        TrendsCalculator.entries(allEntries, in: selectedRange, oldestEntryDate: oldestEntryDate)
    }

    private var dataPoints: [TrendsDataPoint] {
        TrendsCalculator.dataPoints(for: rangedEntries, range: selectedRange, oldestEntryDate: oldestEntryDate)
    }

    private var weekdayCounts: [WeekdayCount] {
        TrendsCalculator.weekdayCounts(in: rangedEntries, calendar: .lummiCalendar(locale: locale))
    }

    private var daysJournaled: Int { InsightsCalculator.uniqueDaysCount(in: rangedEntries) }
    private var bestStreak: Int { InsightsCalculator.longestStreak(in: rangedEntries) }

    var body: some View {
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
                    rangePicker

                    summaryCards

                    TrendsSection(title: "Joys Over Time") {
                        volumeChart
                    }

                    TrendsSection(title: "By Weekday") {
                        weekdayChart
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

    // MARK: - Range Picker

    private var rangePicker: some View {
        HStack(spacing: 4) {
            ForEach(TrendsRange.allCases) { range in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                        selectedRange = range
                    }
                } label: {
                    Text(range.title)
                        .font(.lummiFont(size: 13, weight: selectedRange == range ? .bold : .regular))
                        .foregroundColor(themeManager.currentTheme.textColor.opacity(selectedRange == range ? 1 : 0.5))
                        .minimumScaleFactor(0.8)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            Capsule().fill(themeManager.currentTheme.textColor.opacity(selectedRange == range ? CardOpacity.fill * 3 : 0))
                        )
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(selectedRange == range ? [.isSelected] : [])
            }
        }
        .padding(4)
        .cardBackground(Capsule())
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

    // MARK: - Charts

    private var volumeChart: some View {
        Chart(dataPoints) { point in
            BarMark(
                x: .value("Period", point.periodStart, unit: selectedRange.component),
                y: .value("Joys", point.count)
            )
            .foregroundStyle(trendsGradient)
            .cornerRadius(3)
        }
        .chartXAxis {
            // `.stride` places one tick per actual bar (each calendar day or month), unlike `.automatic`,
            // which interpolates evenly spaced ticks across the continuous date range and can land more
            // than one tick inside the same bar, duplicating its label (e.g. two ticks reading "Aug").
            AxisMarks(values: .stride(by: selectedRange.component, count: selectedRange == .month ? 5 : 1)) {
                AxisValueLabel(format: selectedRange == .month ? .dateTime.day() : .dateTime.month(.abbreviated))
                    .font(.lummiFont(size: 10))
                    .foregroundStyle(themeManager.currentTheme.textColor.opacity(0.5))
            }
        }
        .chartYAxis { yAxisMarks }
        .frame(height: 160)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("Joys Over Time"))
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
        .accessibilityLabel(Text("By Weekday"))
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

    // A distinct color for the weekday chart, so it doesn't read as a continuation of "Joys Over Time" above it.
    private var weekdayGradient: LinearGradient {
        LinearGradient(
            colors: [Color(red: 0.55, green: 0.85, blue: 0.55), Color(red: 0.15, green: 0.55, blue: 0.35)],
            startPoint: .top, endPoint: .bottom
        )
    }
}

// MARK: - UI Components

// Section title above a chart, matching Insights' "Highlights"/"Recall" section headers.
private struct TrendsSection<Content: View>: View {
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
    TrendsView(isShowingTrends: .constant(true))
        .previewEnvironment()
}
#endif
