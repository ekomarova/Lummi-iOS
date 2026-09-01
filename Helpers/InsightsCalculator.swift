//
//  Copyright (c) 2026, Evseniia Komarova.
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//  - Redistributions of source code must retain the above copyright notice,
//    this list of conditions and the following disclaimer.
//  - Redistributions in binary form must reproduce the above copyright notice,
//    this list of conditions and the following disclaimer in the documentation
//    and/or other materials provided with the distribution.
//  - Neither the name of the copyright holder nor the names of its contributors
//    may be used to endorse or promote products derived from this software
//    without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
//  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
//  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
//  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
//  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
//  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
//  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
//  THE POSSIBILITY OF SUCH DAMAGE.
//

import Foundation

struct InsightsCalculator {
    
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
        return max(0, 4 - uniqueCount)
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
        
        let endHour = (peakHour + 2) % 24
        
        guard let startDate = calendar.date(from: DateComponents(hour: peakHour)),
              let endDate = calendar.date(from: DateComponents(hour: endHour)) else { return "-- : --" }
        
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.setLocalizedDateFormatFromTemplate("jmm")
        return "\(formatter.string(from: startDate)) - \(formatter.string(from: endDate))"
    }
}
