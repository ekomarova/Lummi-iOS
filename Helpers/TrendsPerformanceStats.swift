//
//  Required Notice: Copyright Evseniia Komarova (https://github.com/ekomarova)
//
//  Licensed under the PolyForm Noncommercial License 1.0.0.
//  See the LICENSE file in the repository root for full terms.
//  <https://polyformproject.org/licenses/noncommercial/1.0.0>
//

import Foundation

// Everything the Trends cards and charts show for one calendar year, calculated once from a single pass over the
// year's entries instead of filtering the whole journal again for every card and chart.
struct TrendsPerformanceStats {
    let entryCount: Int
    let daysJournaled: Int
    let bestStreak: Int
    let joyfulHours: String
    let dataPoints: [TrendsDataPoint]
    let weekdayCounts: [WeekdayCount]

    static func make(
        from entries: [JoyEntry],
        year: Int,
        locale: Locale,
        now: Date = Date(),
        calendar: Calendar
    ) -> TrendsPerformanceStats {
        let rangedEntries = TrendsCalculator.entries(entries, in: .year(year), now: now, calendar: calendar)
        return TrendsPerformanceStats(
            entryCount: rangedEntries.count,
            daysJournaled: InsightsCalculator.uniqueDaysCount(in: rangedEntries, calendar: calendar),
            bestStreak: InsightsCalculator.longestStreak(in: rangedEntries, calendar: calendar),
            joyfulHours: InsightsCalculator.joyfulHours(entries: rangedEntries, locale: locale, calendar: calendar),
            dataPoints: TrendsCalculator.dataPoints(for: rangedEntries, year: year, now: now, calendar: calendar),
            weekdayCounts: TrendsCalculator.weekdayCounts(in: rangedEntries, calendar: calendar)
        )
    }
}
