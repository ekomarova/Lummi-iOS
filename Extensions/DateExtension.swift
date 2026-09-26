//
//  Copyright (c) 2026, Evseniia Komarova.
//  All rights reserved.
//
//  Licensed under the PolyForm Noncommercial License 1.0.0.
//  See the LICENSE file in the repository root for full terms.
//  <https://polyformproject.org/licenses/noncommercial/1.0.0>
//

import Foundation
import os

// Date helpers: day keys, cached formatting, month boundaries and the current-month check.
extension Date {
    private static let keyFormatter: DateFormatter = {
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: "en_US_POSIX")
        fmt.dateFormat = "yyyy-MM-dd"
        return fmt
    }()

    // Shared by every caller, so access goes through a lock instead of relying on being called from the main thread.
    private static let formatterCache = OSAllocatedUnfairLock<[String: DateFormatter]>(initialState: [:])

    var stringKey: String {
        Date.keyFormatter.string(from: self)
    }

    func format(_ format: String, locale: Locale = .current) -> String {
        let cacheKey = "\(format)|\(locale.identifier)"
        let formatter = Date.formatterCache.withLock { cache -> DateFormatter in
            if let cached = cache[cacheKey] { return cached }
            let created = DateFormatter()
            created.dateFormat = format
            created.locale = locale
            cache[cacheKey] = created
            return created
        }
        return formatter.string(from: self)
    }

    // Full month and year, e.g. "March 2026", capitalized for locales that lowercase month names.
    func monthYearTitle(locale: Locale = .current) -> String {
        format("LLLL yyyy", locale: locale).capitalizedFirstLetter
    }

    // Get the beginning of the month for a specific date
    var startOfMonth: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: components) ?? self
    }
    
    static func isCurrentMonth(_ date: Date) -> Bool {
        Calendar.current.isDate(date, equalTo: Date(), toGranularity: .month)
    }
}
