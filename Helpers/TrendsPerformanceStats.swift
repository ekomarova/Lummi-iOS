//
//  Copyright (c) 2026, Evseniia Komarova.
//  All rights reserved.
//
//  Licensed under the PolyForm Noncommercial License 1.0.0.
//  See the LICENSE file in the repository root for full terms.
//  <https://polyformproject.org/licenses/noncommercial/1.0.0>
//

import Foundation

// Everything the Trends cards and charts show for one range, calculated once from a single pass over the
// ranged entries instead of filtering the whole journal again for every card and chart.
struct TrendsPerformanceStats {
    let entryCount: Int
    let daysJournaled: Int
    let bestStreak: Int
    // Only calculated for `.year`: the Month tab has no Joyful Hours card, since Insights already shows it.
    let joyfulHours: String?
    let dataPoints: [TrendsDataPoint]
    let weekdayCounts: [WeekdayCount]

    static func make(
        from entries: [JoyEntry],
        range: TrendsRange,
        year: Int,
        locale: Locale,
        now: Date = Date(),
        calendar: Calendar = .current
    ) -> TrendsPerformanceStats {
        let rangedEntries = TrendsCalculator.entries(entries, in: range, year: year, now: now, calendar: calendar)
        return TrendsPerformanceStats(
            entryCount: rangedEntries.count,
            daysJournaled: InsightsCalculator.uniqueDaysCount(in: rangedEntries),
            bestStreak: InsightsCalculator.longestStreak(in: rangedEntries),
            joyfulHours: range == .year ? InsightsCalculator.calculateGoldenHours(entries: rangedEntries, locale: locale) : nil,
            dataPoints: TrendsCalculator.dataPoints(for: rangedEntries, range: range, year: year, now: now, calendar: calendar),
            weekdayCounts: TrendsCalculator.weekdayCounts(in: rangedEntries, calendar: .lummiCalendar(locale: locale))
        )
    }
}
