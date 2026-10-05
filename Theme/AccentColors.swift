//
//  Required Notice: Copyright Evseniia Komarova (https://github.com/ekomarova)
//
//  Licensed under the PolyForm Noncommercial License 1.0.0.
//  See the LICENSE file in the repository root for full terms.
//  <https://polyformproject.org/licenses/noncommercial/1.0.0>
//

import SwiftUI

// Data/accent colors shared by Insights, Trends and Settings. Unlike `AppTheme`, these do not
// change between light and dark mode, so they live outside the theme protocol.
enum AccentColors {
    static let joys = Color(red: 1.0, green: 0.55, blue: 0.1)
    static let joysGradient = [Color(red: 1.0, green: 0.8, blue: 0.3), Color(red: 0.2, green: 0.6, blue: 0.3)]

    static let activeDays = Color(red: 0.3, green: 0.6, blue: 0.95)
    static let activeDaysGradient = [Color(red: 0.5, green: 0.75, blue: 1.0), Color(red: 0.3, green: 0.4, blue: 0.85)]

    static let streak = Color(red: 0.95, green: 0.2, blue: 0.2)
    static let streakGradient = [Color(red: 1.0, green: 0.8, blue: 0.3), Color(red: 0.95, green: 0.4, blue: 0.1)]

    static let joyfulHoursGradient = [Color(red: 0.6, green: 0.3, blue: 0.8), Color(red: 1.0, green: 0.8, blue: 0.3)]

    static let trendsVolumeGradient = [Color(red: 0.75, green: 0.6, blue: 0.95), Color(red: 0.45, green: 0.25, blue: 0.75)]
    static let weekdayGradient = [Color(red: 0.55, green: 0.85, blue: 0.55), Color(red: 0.15, green: 0.55, blue: 0.35)]

    // Matches `trendsVolumeGradient`'s darker stop; used for the year-row icon in Trends' "All Time" list.
    static let yearRow = Color(red: 0.45, green: 0.25, blue: 0.75)

    static let destructive = Color(red: 0.95, green: 0.2, blue: 0.3)
    static let syncBannerBackground = Color.red.opacity(0.8)
}
