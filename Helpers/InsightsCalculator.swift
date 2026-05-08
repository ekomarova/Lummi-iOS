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

    static func getMonthComparisonMessage(currentCount: Int, pastCount: Int, isFirstMonth: Bool) -> (text: LocalizedStringResource, id: String) {
        if isFirstMonth {
            return ("let's see how many bright moments this month brings!", "CompMsg_First")
        }
        if currentCount == 0 {
            return ("what beautiful moment will you notice today?", "CompMsg_Zero")
        }
        if currentCount > pastCount {
            return ("you've captured more moments this month than the last", "CompMsg_Growth")
        } else if currentCount == pastCount {
            return ("you continue to find joy in your familiar rhythm!", "CompMsg_Stability")
        } else {
            return ("a quieter month, but remember: every single moment of joy you save matters!", "CompMsg_Decline")
        }
    }
}
