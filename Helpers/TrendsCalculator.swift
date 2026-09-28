//
//  Copyright (c) 2026, Evseniia Komarova.
//  All rights reserved.
//
//  Licensed under the PolyForm Noncommercial License 1.0.0.
//  See the LICENSE file in the repository root for full terms.
//  <https://polyformproject.org/licenses/noncommercial/1.0.0>
//

import Foundation

// Time window for the Trends screen. Each case widens the window and coarsens the chart's granularity,
// mirroring Apple Health's range picker: `.month` plots one bar per day, every wider range plots one bar per month.
enum TrendsRange: CaseIterable, Identifiable {
    case month
    case year
    case allTime

    var id: Self { self }

    var title: LocalizedStringResource {
        switch self {
        case .month: "Month"
        case .year: "Year"
        case .allTime: "All Time"
        }
    }

    // The bar chart's granularity: individual days only make sense once the window has narrowed to a month.
    // Also used directly by the chart view to group `BarMark`s by the same unit.
    var component: Calendar.Component {
        self == .month ? .day : .month
    }
}

// One bar in the Trends chart: either a calendar day or a calendar month, depending on the selected range.
struct TrendsDataPoint: Identifiable, Equatable {
    var id: Date { periodStart }
    let periodStart: Date
    let count: Int
}

// One weekday's entry count, in locale week-start order (e.g. Monday-first for ru/de).
struct WeekdayCount: Identifiable, Equatable {
    var id: Int { weekday }
    // Calendar's own weekday numbering: 1 = Sunday ... 7 = Saturday, matching `Calendar.component(.weekday:)`.
    let weekday: Int
    let count: Int
}

// Pure calculations behind the Trends screen: which entries fall in a selected range, chart-ready
// data points for it, and the weekday distribution used by the habit chart.
struct TrendsCalculator {

    // MARK: - Range

    // The entries that fall inside `range`, anchored to `now`. `oldestEntryDate` is only needed to
    // resolve `.allTime`'s start; when there is no oldest entry yet, every range is empty.
    static func entries(
        _ entries: [JoyEntry],
        in range: TrendsRange,
        now: Date = Date(),
        oldestEntryDate: Date?,
        calendar: Calendar = .current
    ) -> [JoyEntry] {
        guard let start = rangeStart(for: range, now: now, oldestEntryDate: oldestEntryDate, calendar: calendar) else {
            return []
        }
        return entries.filter { $0.date >= start && $0.date <= now }
    }

    // MARK: - Chart data

    // One data point per day (`.month`) or per month (every wider range), oldest first, with a zero
    // count filled in for empty periods so the chart's axis has no gaps.
    static func dataPoints(
        for entries: [JoyEntry],
        range: TrendsRange,
        now: Date = Date(),
        oldestEntryDate: Date?,
        calendar: Calendar = .current
    ) -> [TrendsDataPoint] {
        guard let start = rangeStart(for: range, now: now, oldestEntryDate: oldestEntryDate, calendar: calendar) else {
            return []
        }
        let component = range.component

        var counts = [Date: Int]()
        for entry in entries {
            let periodStart = component == .day
                ? calendar.startOfDay(for: entry.date)
                : (calendar.dateInterval(of: .month, for: entry.date)?.start ?? entry.date)
            counts[periodStart, default: 0] += 1
        }

        let end: Date = component == .day
            ? (calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: now)) ?? now)
            : (calendar.date(byAdding: .month, value: 1, to: calendar.dateInterval(of: .month, for: now)?.start ?? now) ?? now)

        var points = [TrendsDataPoint]()
        var cursor = start
        while cursor < end {
            points.append(TrendsDataPoint(periodStart: cursor, count: counts[cursor] ?? 0))
            guard let next = calendar.date(byAdding: component, value: 1, to: cursor) else { break }
            cursor = next
        }
        return points
    }

    // MARK: - Distributions

    // Entry count for each weekday, ordered starting at the calendar's locale-aware first weekday.
    static func weekdayCounts(in entries: [JoyEntry], calendar: Calendar = .current) -> [WeekdayCount] {
        var counts = [Int: Int]()
        for entry in entries {
            counts[calendar.component(.weekday, from: entry.date), default: 0] += 1
        }
        let orderedWeekdays = (0..<7).map { (calendar.firstWeekday - 1 + $0) % 7 + 1 }
        return orderedWeekdays.map { WeekdayCount(weekday: $0, count: counts[$0] ?? 0) }
    }

    // MARK: - Private

    private static func rangeStart(
        for range: TrendsRange,
        now: Date,
        oldestEntryDate: Date?,
        calendar: Calendar
    ) -> Date? {
        let currentMonthStart = calendar.dateInterval(of: .month, for: now)?.start ?? now
        let oldestMonthStart = oldestEntryDate.map { calendar.dateInterval(of: .month, for: $0)?.start ?? $0 }

        switch range {
        case .month:
            return currentMonthStart
        case .year:
            let naiveStart = calendar.date(byAdding: .month, value: -11, to: currentMonthStart) ?? currentMonthStart
            return clampToOldestMonth(naiveStart, oldestMonthStart: oldestMonthStart)
        case .allTime:
            return oldestMonthStart ?? currentMonthStart
        }
    }

    // A young journal shouldn't pad the chart with empty months from before it existed: the start
    // never reaches earlier than the oldest entry's month, even when the range would normally span further back.
    private static func clampToOldestMonth(_ naiveStart: Date, oldestMonthStart: Date?) -> Date {
        guard let oldestMonthStart else { return naiveStart }
        return max(naiveStart, oldestMonthStart)
    }
}
