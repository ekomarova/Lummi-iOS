//
//  Copyright (c) 2026, Evseniia Komarova.
//  All rights reserved.
//
//  Licensed under the PolyForm Noncommercial License 1.0.0.
//  See the LICENSE file in the repository root for full terms.
//  <https://polyformproject.org/licenses/noncommercial/1.0.0>
//

import Foundation

// Offline sanity check for the device clock, so a record is never created with a bogus past date.
// Deliberately checks only a fixed lower bound: comparing against existing records would let a single
// entry saved with a clock set far ahead (or synced from another device) block saving for good
// once the clock is corrected.
enum DeviceClockCheck {
    // The earliest date the app supports: 2026-01-01 in the current time zone. Built from date components
    // (not a fixed UTC instant) so its start-of-month is always January 2026, in any time zone. The calendar
    // is explicitly Gregorian: Calendar.current follows the user's region setting, where "year 2026" would
    // mean a different moment (Japanese era year, Buddhist Era, Hijri, ...).
    static var earliestSupportedDate: Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .current
        return calendar.date(from: DateComponents(year: 2026, month: 1, day: 1)) ?? Date(timeIntervalSince1970: 1_767_225_600)
    }

    static func isPlausible(now: Date) -> Bool {
        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("-UI_TESTING_SIMULATE_BAD_DEVICE_DATE") { return false }
        #endif
        return now >= earliestSupportedDate
    }
}
