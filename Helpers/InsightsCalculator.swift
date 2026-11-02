//
//  Required Notice: Copyright Evseniia Komarova (https://github.com/ekomarova)
//
//  Licensed under the PolyForm Noncommercial License 1.0.0.
//  See the LICENSE file in the repository root for full terms.
//  <https://polyformproject.org/licenses/noncommercial/1.0.0>
//

import Foundation

// Pure calculations behind the Insights screen: streaks, unique days and joyful hours.
struct InsightsCalculator {

    private static let joyfulHoursWindowSize = 3
    private static let hoursPerDay = 24

    // MARK: - General Stats

    static func uniqueDaysCount(in entries: [JoyEntry], calendar: Calendar = .current) -> Int {
        uniqueDays(in: entries, calendar: calendar).count
    }

    static func longestStreak(in entries: [JoyEntry], calendar: Calendar = .current) -> Int {
        guard !entries.isEmpty else { return 0 }

        let days = uniqueDays(in: entries, calendar: calendar).sorted(by: <)

        var currentStreak = 1
        var maxStreak = 1

        for index in 1..<days.count {
            let difference = calendar.dateComponents([.day], from: days[index - 1], to: days[index]).day ?? 0

            if difference == 1 {
                currentStreak += 1
                maxStreak = max(maxStreak, currentStreak)
            } else {
                currentStreak = 1
            }
        }
        return maxStreak
    }

    // The start of every day that has at least one entry.
    private static func uniqueDays(in entries: [JoyEntry], calendar: Calendar) -> Set<Date> {
        Set(entries.map { calendar.startOfDay(for: $0.date) })
    }

    // MARK: - Advanced Metrics

    // The `joyfulHoursWindowSize`-hour stretch of the day with the most entries, e.g. "18:00 - 21:00".
    static func joyfulHours(entries: [JoyEntry], locale: Locale, calendar: Calendar = .current) -> String {
        guard !entries.isEmpty else { return noJoyfulHours(locale: locale) }

        var hourCounts = [Int: Int]()
        var lastEntryDateForHour = [Int: Date]()

        for entry in entries {
            let hour = calendar.component(.hour, from: entry.date)
            hourCounts[hour, default: 0] += 1

            // Track the most recent chronological entry for each hour to break ties predictably
            if let existingDate = lastEntryDateForHour[hour] {
                if entry.date > existingDate {
                    lastEntryDateForHour[hour] = entry.date
                }
            } else {
                lastEntryDateForHour[hour] = entry.date
            }
        }

        // Slide a window of `joyfulHoursWindowSize` hours around the clock (wrapping past midnight)
        // and pick the one that contains the most entries. Windows only start at an hour that has
        // entries: any best window can be shifted to begin at its first occupied hour.
        var bestStart = 0
        var bestCount = -1
        var bestLatest = Date.distantPast

        for start in hourCounts.keys.sorted() {
            let hoursInWindow = (0..<joyfulHoursWindowSize).map { (start + $0) % hoursPerDay }
            let count = hoursInWindow.reduce(0) { $0 + (hourCounts[$1] ?? 0) }
            // If counts are equal, deterministically pick the window with the latest overall entry
            let latest = hoursInWindow.compactMap { lastEntryDateForHour[$0] }.max() ?? .distantPast

            if count > bestCount || (count == bestCount && latest > bestLatest) {
                bestStart = start
                bestCount = count
                bestLatest = latest
            }
        }

        let peakHour = bestStart
        let endHour = (peakHour + joyfulHoursWindowSize) % hoursPerDay

        guard let startDate = calendar.date(from: DateComponents(hour: peakHour)),
              let endDate = calendar.date(from: DateComponents(hour: endHour)) else { return noJoyfulHours(locale: locale) }

        let style = Date.FormatStyle(locale: locale, calendar: calendar, timeZone: calendar.timeZone).hour().minute()
        return "\(startDate.formatted(style)) - \(endDate.formatted(style))"
    }

    // Shown in place of the range when there are no entries to find it in. Looked up in `locale`, which is the app's
    // language and not necessarily the system's.
    private static func noJoyfulHours(locale: Locale) -> String {
        var placeholder: LocalizedStringResource = "-- : --"
        placeholder.locale = locale
        return String(localized: placeholder)
    }
}
