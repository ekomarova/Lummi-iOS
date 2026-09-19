//
//  Copyright (c) 2026, Evseniia Komarova.
//  All rights reserved.
//
//  Licensed under the PolyForm Noncommercial License 1.0.0.
//  See the LICENSE file in the repository root for full terms.
//  <https://polyformproject.org/licenses/noncommercial/1.0.0>
//

import Foundation

extension Date {
    private static let keyFormatter: DateFormatter = {
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: "en_US_POSIX")
        fmt.dateFormat = "yyyy-MM-dd"
        return fmt
    }()

    private static var formatterCache: [String: DateFormatter] = [:]

    var stringKey: String {
        Date.keyFormatter.string(from: self)
    }

    func format(_ format: String, locale: Locale = .current) -> String {
        let cacheKey = "\(format)|\(locale.identifier)"
        if let cached = Date.formatterCache[cacheKey] {
            return cached.string(from: self)
        }
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = locale
        Date.formatterCache[cacheKey] = formatter
        return formatter.string(from: self)
    }
    
    // Get the beginning of the month for a specific date
    var startOfMonth: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: components) ?? self
    }
    
    //  Get the previous month
    func previousMonth() -> Date {
        return Calendar.current.date(byAdding: .month, value: -1, to: self) ?? self
    }
    
    static func isCurrentMonth(_ date: Date) -> Bool {
        Calendar.current.isDate(date, equalTo: Date(), toGranularity: .month)
    }
    
    static func isOldestMonth(selectedMonth: Date, allEntries: [JoyEntry]) -> Bool {
        guard let oldestEntry = allEntries.min(by: { $0.date < $1.date }) else { return true }
        let oldestMonth = max(oldestEntry.date.startOfMonth, earliestAllowedMonth)
        return selectedMonth <= oldestMonth
    }
    
    // No genuine record can predate the earliest supported date, so month ranges start no earlier than this month.
    // Keeps a record with a bogus date (e.g. wrong device clock) from opening decades of empty months
    static var earliestAllowedMonth: Date {
        DeviceClockCheck.earliestSupportedDate.startOfMonth
    }
    
}
