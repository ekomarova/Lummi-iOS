//
//  Required Notice: Copyright Evseniia Komarova (https://github.com/ekomarova)
//
//  Licensed under the PolyForm Noncommercial License 1.0.0.
//  See the LICENSE file in the repository root for full terms.
//  <https://polyformproject.org/licenses/noncommercial/1.0.0>
//

import Foundation
import os

// How `Date.monthName(style:locale:)` spells a month.
enum MonthNameStyle {
    // The whole name: "September".
    case full
    // The locale's abbreviation as it is: "Sep", but with a trailing period in some locales ("Сент.").
    case abbreviated
    // Up to three letters and no period, so every month label has the same width.
    case threeLetters
}

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

    // The month's name in `locale`, with a capital first letter. Foundation lowercases month names in locales like
    // Russian ("сентября"), unlike English ("September"), hence `capitalizedFirstLetter`. Built by hand rather than via
    // `AxisValueLabel(format:)` for chart axes, because Swift Charts' axis formatting does not reliably follow the app's
    // in-app language selection from the environment.
    func monthName(style: MonthNameStyle, locale: Locale = .current) -> String {
        switch style {
        case .full:
            return format("MMMM", locale: locale).capitalizedFirstLetter
        case .abbreviated:
            return format("MMM", locale: locale).capitalizedFirstLetter
        case .threeLetters:
            // Some locales' abbreviated forms carry a trailing period and run longer than three letters
            // (Russian's "нояб." vs. English's "Nov"); dropping the period and clipping to three letters keeps every
            // label the same width so none crowd or overlap their neighbors.
            let month = formatted(Date.FormatStyle(locale: locale).month(.abbreviated))
            return String(month.replacingOccurrences(of: ".", with: "").prefix(3)).capitalizedFirstLetter
        }
    }

    // Get the beginning of the month for a specific date
    var startOfMonth: Date {
        Calendar.current.monthStart(for: self) ?? self
    }
}
