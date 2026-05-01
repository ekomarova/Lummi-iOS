//
//  Calendar Cell
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
