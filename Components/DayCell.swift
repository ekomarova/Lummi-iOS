//
//  Copyright (c) 2026, Evseniia Komarova.
//  All rights reserved.
//
//  Licensed under the PolyForm Noncommercial License 1.0.0.
//  See the LICENSE file in the repository root for full terms.
//  <https://polyformproject.org/licenses/noncommercial/1.0.0>
//

import SwiftUI

struct DayCell: View {
    @Environment(ThemeManager.self) private var themeManager
    let day: Int
    let isFilled: Bool
    let isToday: Bool
    let isSelected: Bool
    
    let dateKey: String
    
    var body: some View {
        ZStack {
            VStack(spacing: 4) {
                if isFilled {
                    Image(systemName: "star.fill")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(themeManager.currentTheme.dayFilledColor)
                        .frame(width: 12, height: 12)
                } else {
                    Color.clear
                        .frame(width: 12, height: 12)
                }

                Text("\(day)")
                    .font(.system(size: 15, weight: .light, design: .default))
                    .foregroundColor(
                        isToday ? themeManager.currentTheme.textColor :
                            (isFilled ? themeManager.currentTheme.dayFilledColor :
                                themeManager.currentTheme.textColor
                                .opacity(themeManager.currentTheme.inactiveOpacity))
                    )
            }
        }
        .frame(height: 38)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(day)")
        .accessibilityIdentifier("DayCell_\(dateKey)")
        .accessibilityAddTraits(.isButton)
        .accessibilityValue(isFilled ? "Filled" : "Empty")
    }
}

#if DEBUG
#Preview {
    HStack {
        DayCell(day: 12, isFilled: true, isToday: false, isSelected: false, dateKey: "2026-03-12")
        DayCell(day: 13, isFilled: false, isToday: true, isSelected: true, dateKey: "2026-03-13")
    }
    .previewEnvironment()
}
#endif
