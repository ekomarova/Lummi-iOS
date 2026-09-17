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
                    .font(.system(size: AdaptiveLayout.getSize(for: 15), weight: .light, design: .default))
                    .foregroundColor(
                        isToday ? themeManager.currentTheme.textColor :
                            (isFilled ? themeManager.currentTheme.dayFilledColor :
                                themeManager.currentTheme.textColor
                                .opacity(themeManager.currentTheme.inactiveOpacity))
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
