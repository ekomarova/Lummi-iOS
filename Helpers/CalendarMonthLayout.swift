//
//  Copyright (c) 2026, Evseniia Komarova.
//  All rights reserved.
//
//  Licensed under the PolyForm Noncommercial License 1.0.0.
//  See the LICENSE file in the repository root for full terms.
//  <https://polyformproject.org/licenses/noncommercial/1.0.0>
//
import Foundation

// Calendar math behind the month grid. Every function returns an optional or an empty
// collection when the calendar cannot produce a value, so callers never render made-up dates.
enum CalendarMonthLayout {

    // First days of every month from the month of `firstEntryDate` (or `now` when nil)
    // up to and including the month of `now`.
    static func monthStarts(firstEntryDate: Date?, now: Date, calendar: Calendar = .current) -> [Date] {
        guard let startMonth = monthStart(of: firstEntryDate ?? now, calendar: calendar),
              let currentMonth = monthStart(of: now, calendar: calendar) else { return [] }

        var result: [Date] = []
        var iterator = startMonth
        while iterator <= currentMonth {
            result.append(iterator)
            guard let next = calendar.date(byAdding: .month, value: 1, to: iterator) else { break }
            iterator = next
        }
        return result
    }

    static func daysInMonth(_ monthDate: Date, calendar: Calendar = .current) -> Int? {
        calendar.range(of: .day, in: .month, for: monthDate)?.count
    }

    // Number of empty cells before the first day, given the calendar's first weekday.
    static func firstDayOffset(_ monthDate: Date, calendar: Calendar = .current) -> Int {
        guard let first = monthStart(of: monthDate, calendar: calendar) else { return 0 }
        let firstWeekday = calendar.component(.weekday, from: first)
        return (firstWeekday - calendar.firstWeekday + 7) % 7
    }

    static func date(forDay day: Int, inMonth monthDate: Date, calendar: Calendar = .current) -> Date? {
        var components = calendar.dateComponents([.year, .month], from: monthDate)
        components.day = day
        return calendar.date(from: components)
    }

    // All days of the month; empty if the calendar cannot resolve the month.
    static func dates(inMonth monthDate: Date, calendar: Calendar = .current) -> [Date] {
        guard let count = daysInMonth(monthDate, calendar: calendar) else { return [] }
        return (1...count).compactMap { date(forDay: $0, inMonth: monthDate, calendar: calendar) }
    }

    private static func monthStart(of date: Date, calendar: Calendar) -> Date? {
        calendar.date(from: calendar.dateComponents([.year, .month], from: date))
    }
}
