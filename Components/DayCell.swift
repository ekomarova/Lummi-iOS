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

    
    var body: some View {
        ZStack {
            if isSelected {
                Circle()
                    .fill(themeManager.currentTheme.calendarContentColor.opacity(0.1))
                    .frame(width: 40, height: 40)
            }

            if isToday {
                Circle()
                    .fill(themeManager.currentTheme.todayGlow.opacity(0.3))
                    .frame(width: 35, height: 35)
                    .blur(radius: 10)
            }

            VStack(spacing: 4) {
                if isFilled {
                    Image(systemName: "star.fill")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(themeManager.currentTheme.calendarContentColor)
                        .frame(width: 12, height: 12)
                } else {
                    Color.clear
                        .frame(width: 12, height: 12)
                }

                Text("\(day)")
                    .font(.system(size: 15, weight: isToday ? .black : .bold, design: .monospaced))
                    .foregroundColor(
                        isToday ? themeManager.currentTheme.todayColor :
                        (isFilled ? themeManager.currentTheme.calendarContentColor : themeManager.currentTheme.calendarContentColor.opacity(themeManager.currentTheme.inactiveOpacity))
                    )
                    .shadow(color: .black.opacity(isToday ? 0.8 : 0), radius: 1)
            }
        }
        .frame(height: 38)
    }
}
