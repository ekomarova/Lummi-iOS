//
//  Copyright (c) 2026, Evseniia Komarova.
//  All rights reserved.
//
//  Licensed under the PolyForm Noncommercial License 1.0.0.
//  See the LICENSE file in the repository root for full terms.
//  <https://polyformproject.org/licenses/noncommercial/1.0.0>
//

import Foundation

struct InsightsCalculator {

    private static let minimumDaysForReport = 4
    private static let goldenHourWindowSize = 3

    // MARK: - General Stats
    
    static func filterEntries(_ entries: [JoyEntry], for month: Date) -> [JoyEntry] {
        let calendar = Calendar.current
        return entries.filter { calendar.isDate($0.date, equalTo: month, toGranularity: .month) }
    }
    
    static func uniqueDaysCount(in entries: [JoyEntry]) -> Int {
        let calendar = Calendar.current
        return Set(entries.map { calendar.startOfDay(for: $0.date) }).count
    }
    
    static func daysNeededForReport(in entries: [JoyEntry]) -> Int {
        let uniqueCount = uniqueDaysCount(in: entries)
        return max(0, minimumDaysForReport - uniqueCount)
    }
    
    static func longestStreak(in entries: [JoyEntry]) -> Int {
        guard !entries.isEmpty else { return 0 }
        
        let calendar = Calendar.current
        let uniqueDays = Set(entries.map { calendar.startOfDay(for: $0.date) }).sorted(by: <)
        
        var currentStreak = 1
        var maxStreak = 1
        
        for index in 1..<uniqueDays.count {
            let difference = calendar.dateComponents([.day], from: uniqueDays[index-1], to: uniqueDays[index]).day ?? 0
            
            if difference == 1 {
                currentStreak += 1
                maxStreak = max(maxStreak, currentStreak)
            } else {
                currentStreak = 1
            }
        }
        return maxStreak
    }

    // MARK: - Advanced Metrics

    static func calculateGoldenHours(entries: [JoyEntry], locale: Locale) -> String {
        guard !entries.isEmpty else { return "-- : --" }
        
        var hourCounts = [Int: Int]()
        var lastEntryDateForHour = [Int: Date]()
        
        let calendar = Calendar.current
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
        
        guard let peakHour = hourCounts.max(by: { lhs, rhs in
            if lhs.value == rhs.value {
                // If counts are equal, deterministically pick the one with the latest overall entry
                let dateA = lastEntryDateForHour[lhs.key] ?? .distantPast
                let dateB = lastEntryDateForHour[rhs.key] ?? .distantPast
                return dateA < dateB
            }
            return lhs.value < rhs.value
        })?.key else { return "-- : --" }
        
        let endHour = (peakHour + goldenHourWindowSize) % 24
        
        guard let startDate = calendar.date(from: DateComponents(hour: peakHour)),
              let endDate = calendar.date(from: DateComponents(hour: endHour)) else { return "-- : --" }
        
        let style = Date.FormatStyle(locale: locale).hour().minute()
        return "\(startDate.formatted(style)) - \(endDate.formatted(style))"
    }
}
