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

import SwiftUI

struct DayCell: View {
    @EnvironmentObject var themeManager: ThemeManager
    let day: Int
    let isFilled: Bool
    let isToday: Bool
    let isSelected: Bool
    
    let dateKey: String

    
    var body: some View {
        ZStack {
            VStack(spacing: AdaptiveLayout.getSize(for: 4)) {
                if isFilled {
                    Image(systemName: "star.fill")
                        .font(.system(size: AdaptiveLayout.getSize(for: 8), weight: .bold))
                        .foregroundColor(themeManager.currentTheme.dayFilledColor)
                        .frame(width: AdaptiveLayout.getSize(for: 12), height: AdaptiveLayout.getSize(for: 12))
                } else {
                    Color.clear
                        .frame(width: AdaptiveLayout.getSize(for: 12), height: AdaptiveLayout.getSize(for: 12))
                }

                Text("\(day)")
                    .font(.system(size: AdaptiveLayout.getSize(for: 15), weight: isToday ? .bold : .light, design: .monospaced))
                    .foregroundColor(
                        isToday ? themeManager.currentTheme.todayColor :
                        (isFilled ? themeManager.currentTheme.dayFilledColor : themeManager.currentTheme.calendarContentColor.opacity(themeManager.currentTheme.inactiveOpacity))
                    )
            }
        }
        .frame(height: AdaptiveLayout.getSize(for: 38))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(day)")
        .accessibilityIdentifier("DayCell_\(dateKey)")
        .accessibilityAddTraits(.isButton)
        .accessibilityValue(isFilled ? "Filled" : "Empty")
    }
}
