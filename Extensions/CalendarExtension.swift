//
//  Copyright (c) 2026, Evseniia Komarova.
//  All rights reserved.
//
//  Licensed under the PolyForm Noncommercial License 1.0.0.
//  See the LICENSE file in the repository root for full terms.
//  <https://polyformproject.org/licenses/noncommercial/1.0.0>
//

import Foundation

// This app's shared way to build a locale-aware calendar (e.g. correct week start day
// and weekday names for the user's language), used by the calendar screen's month grid
// and weekday header so both stay in sync.
extension Calendar {
    static func lummiCalendar(locale: Locale) -> Calendar {
        var calendar = Calendar.current
        calendar.locale = locale
        return calendar
    }
}
