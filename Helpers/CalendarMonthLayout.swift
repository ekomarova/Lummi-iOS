//
//  Required Notice: Copyright Evseniia Komarova (https://github.com/ekomarova)
//
//  Licensed under the PolyForm Noncommercial License 1.0.0.
//  See the LICENSE file in the repository root for full terms.
//  <https://polyformproject.org/licenses/noncommercial/1.0.0>
//
import Foundation

// Calendar math behind the month grid. Every function returns an optional or an empty
// collection when the calendar cannot produce a value, so callers never render made-up dates.
enum CalendarMonthLayout {

    static func daysInMonth(_ monthDate: Date, calendar: Calendar = .current) -> Int? {
        calendar.range(of: .day, in: .month, for: monthDate)?.count
    }

    // Number of empty cells before the first day, given the calendar's first weekday.
    static func firstDayOffset(_ monthDate: Date, calendar: Calendar = .current) -> Int {
        guard let first = calendar.monthStart(for: monthDate) else { return 0 }
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

    // The month as rows of seven cells, in the calendar's weekday order. A cell is nil before the first and after the
    // last day of the month, so every row is full; empty if the calendar cannot resolve the month.
    static func weeks(inMonth monthDate: Date, calendar: Calendar = .current) -> [[Date?]] {
        let days = dates(inMonth: monthDate, calendar: calendar)
        guard !days.isEmpty else { return [] }
        let cells: [Date?] = Array(repeating: nil, count: firstDayOffset(monthDate, calendar: calendar)) + days
        return stride(from: 0, to: cells.count, by: 7).map { start in
            let row = Array(cells[start..<min(start + 7, cells.count)])
            return row + Array(repeating: nil, count: 7 - row.count)
        }
    }

    // Index of the row of `weeks(inMonth:)` that holds `date`; nil when `date` is not in that month.
    static func weekIndex(of date: Date, inMonth monthDate: Date, calendar: Calendar = .current) -> Int? {
        weeks(inMonth: monthDate, calendar: calendar).firstIndex { week in
            week.contains { $0.map { calendar.isDate($0, inSameDayAs: date) } ?? false }
        }
    }
}
