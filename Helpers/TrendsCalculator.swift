//
//  Copyright (c) 2026, Evseniia Komarova.
//  All rights reserved.
//
//  Licensed under the PolyForm Noncommercial License 1.0.0.
//  See the LICENSE file in the repository root for full terms.
//  <https://polyformproject.org/licenses/noncommercial/1.0.0>
//

import Foundation

// Time window for the Trends screen. `.month` plots one bar per day of the current calendar month;
// `.year` plots one bar per month of a chosen calendar year (browsable, not necessarily this year).
enum TrendsRange: Equatable {
    case month
    case year

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
// data points for it, the weekday distribution used by the habit chart, and the "All Time" year list.
struct TrendsCalculator {

    // MARK: - Range

    // The entries that fall inside `range`. For `.year`, `year` is whichever calendar year the browser is
    // currently showing (not necessarily the current one); a `year` later than `now`'s returns nothing.
    // `oldestEntryDate` only affects the current year (see `bounds`); pass `nil` if it is not known.
    static func entries(
        _ entries: [JoyEntry],
        in range: TrendsRange,
        year: Int,
        oldestEntryDate: Date?,
        now: Date = Date(),
        calendar: Calendar = .current
    ) -> [JoyEntry] {
        guard let bounds = bounds(for: range, year: year, oldestEntryDate: oldestEntryDate, now: now, calendar: calendar)
        else { return [] }
        return entries.filter { $0.date >= bounds.start && $0.date < bounds.end }
    }

    // MARK: - Chart data

    // One data point per day (`.month`) or per month (`.year`), oldest first, with a zero count filled in
    // for empty periods so the chart's axis has no gaps. A past year always spans its full twelve months,
    // no clamping needed since it is over and done with; the current year stops at today so no bar
    // represents a day that has not happened yet, and starts at the journal's first entry if that landed
    // later in the year, so months before the journal existed are not drawn as empty.
    static func dataPoints(
        for entries: [JoyEntry],
        range: TrendsRange,
        year: Int,
        oldestEntryDate: Date?,
        now: Date = Date(),
        calendar: Calendar = .current
    ) -> [TrendsDataPoint] {
        guard let bounds = bounds(for: range, year: year, oldestEntryDate: oldestEntryDate, now: now, calendar: calendar)
        else { return [] }
        let component = range.component

        var counts = [Date: Int]()
        for entry in entries {
            let periodStart = component == .day
                ? calendar.startOfDay(for: entry.date)
                : (calendar.dateInterval(of: .month, for: entry.date)?.start ?? entry.date)
            counts[periodStart, default: 0] += 1
        }

        var points = [TrendsDataPoint]()
        var cursor = bounds.start
        while cursor < bounds.end {
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

    // MARK: - Year list

    // Every calendar year from the oldest entry's year through the current one, newest first, for the
    // "All Time" list that opens a year's detail page. Always includes at least the current year, even
    // with no entries yet, so the list is never empty.
    static func availableYears(oldestEntryDate: Date?, now: Date = Date(), calendar: Calendar = .current) -> [Int] {
        let currentYear = calendar.component(.year, from: now)
        let oldestYear = oldestEntryDate.map { calendar.component(.year, from: $0) } ?? currentYear
        guard oldestYear <= currentYear else { return [currentYear] }
        return Array((oldestYear...currentYear).reversed())
    }

    // MARK: - Private

    private static func bounds(
        for range: TrendsRange,
        year: Int,
        oldestEntryDate: Date?,
        now: Date,
        calendar: Calendar
    ) -> (start: Date, end: Date)? {
        switch range {
        case .month:
            guard let interval = calendar.dateInterval(of: .month, for: now) else { return nil }
            let todayEnd = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: now)) ?? interval.end
            return (interval.start, min(todayEnd, interval.end))
        case .year:
            guard let yearStart = calendar.date(from: DateComponents(year: year, month: 1, day: 1)),
                  let yearInterval = calendar.dateInterval(of: .year, for: yearStart) else { return nil }
            let currentYear = calendar.component(.year, from: now)
            guard year <= currentYear else { return nil } // the browser never reaches into the future
            guard year == currentYear else { return (yearInterval.start, yearInterval.end) } // a past year: all 12 months, unclamped

            // The current year only: never start before the journal's very first entry (if that landed
            // later within this same year — an entry from an earlier year never clamps anything, since
            // `yearInterval.start` is already later than it), and never draw past today.
            let oldestMonthStart = oldestEntryDate.map { calendar.dateInterval(of: .month, for: $0)?.start ?? $0 }
            let clampedStart = oldestMonthStart.map { max(yearInterval.start, $0) } ?? yearInterval.start
            let monthCappedEnd = calendar.date(
                byAdding: .month, value: 1, to: calendar.dateInterval(of: .month, for: now)?.start ?? now
            ) ?? yearInterval.end
            return (clampedStart, min(monthCappedEnd, yearInterval.end))
        }
    }
}
