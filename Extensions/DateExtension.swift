//
//  Required Notice: Copyright Evseniia Komarova (https://github.com/ekomarova)
//
//  Licensed under the PolyForm Noncommercial License 1.0.0.
//  See the LICENSE file in the repository root for full terms.
//  <https://polyformproject.org/licenses/noncommercial/1.0.0>
//

import Foundation
import os

// Date helpers: cached formatting, month boundaries and the current-month check.
extension Date {
    // Shared by every caller, so access goes through a lock instead of relying on being called from the main thread.
    private static let formatterCache = OSAllocatedUnfairLock<[String: DateFormatter]>(initialState: [:])

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

    // Get the beginning of the month for a specific date
    var startOfMonth: Date {
        Calendar.current.monthStart(for: self) ?? self
    }
}
