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
                    .font(.system(size: 15, weight: isToday ? .bold : .light, design: .monospaced))
                    .foregroundColor(
                        isToday ? themeManager.currentTheme.todayColor :
                        (isFilled ? themeManager.currentTheme.dayFilledColor : themeManager.currentTheme.calendarContentColor.opacity(themeManager.currentTheme.inactiveOpacity))
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
