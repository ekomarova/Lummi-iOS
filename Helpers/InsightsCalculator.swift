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

    static func longestStreak(in entries: [JoyEntry]) -> Int {
        guard !entries.isEmpty else { return 0 }
        
        let calendar = Calendar.current
        let uniqueDays = Set(entries.map { calendar.startOfDay(for: $0.date) }).sorted(by: <)
        
        var currentStreak = 1
        var maxStreak = 1
        
        for i in 1..<uniqueDays.count {
            let difference = calendar.dateComponents([.day], from: uniqueDays[i-1], to: uniqueDays[i]).day ?? 0
            
            if difference == 1 {
                currentStreak += 1
                maxStreak = max(maxStreak, currentStreak)
            } else {
                currentStreak = 1
            }
        }
        return maxStreak
    }

static func getMonthlyJoysMessage(count: Int, isCurrentMonth: Bool) -> (text: LocalizedStringResource, id: String) {
        if count == 0 {
            return isCurrentMonth
                ? ("Your journey of joy starts here. Record a moment to begin!", "JoysMsg_CurrentZero")
                : ("A quiet month with no recorded moments", "JoysMsg_PastZero")
        } else if count < 10 {
            return isCurrentMonth
                ? ("Beautiful moments collected so far! Keep your eyes open for more!", "JoysMsg_CurrentFew")
                : ("Beautiful moments collected during this month", "JoysMsg_PastFew")
        } else {
            return isCurrentMonth
                ? ("Beautiful moments experienced so far! Look at you go!", "JoysMsg_CurrentMany")
                : ("Beautiful moments experienced during this month!", "JoysMsg_PastMany")
        }
    }

static func getMonthlyStreakMessage(streak: Int, isCurrentMonth: Bool) -> (text: LocalizedStringResource, id: String) {
        if streak == 0 {
            return isCurrentMonth
                ? ("Ready for some joy? Record a moment today to start your streak!", "StreakMsg_CurrentZero")
                : ("No daily streaks were built this month", "StreakMsg_PastZero")
        } else if streak == 1 {
            return isCurrentMonth
                ? ("Day of joy down! Come back tomorrow to keep it going", "StreakMsg_CurrentOne")
                : ("Day of joy found. Every moment counts!", "StreakMsg_PastOne")
        } else {
            return isCurrentMonth
                ? ("Days of joy in a row! Keep this beautiful momentum going!", "StreakMsg_CurrentMany")
                : ("Days of joy in a row! That was your best streak", "StreakMsg_PastMany")
        }
    }

static func getMonthComparisonMessage(currentCount: Int, pastCount: Int, isFirstMonth: Bool) -> (text: LocalizedStringResource, id: String) {
        if isFirstMonth {
            return ("The beginning of a beautiful story! Let's see how many bright moments this month brings", "CompMsg_First")
        }
        if currentCount == 0 {
            return ("Your journal is ready for new entries. What joy will happen today?", "CompMsg_Zero")
        }
        if currentCount > pastCount {
            return ("Your ability to notice joy is growing! You have more moments this month than the last", "CompMsg_Growth")
        } else if currentCount == pastCount {
            return ("Wonderful consistency! You continue to find joy in your familiar rhythm", "CompMsg_Stability")
        } else {
            // currentCount < pastCount
            return ("Every saved moment matters! You are continuing your collection of joy!", "CompMsg_Decline")
        }
    }
}
