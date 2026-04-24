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
                Circle().fill(themeManager.currentTheme.textColor.opacity(0.1)).frame(width: 40)
            }
            
            if isFilled {
                NeonStarView(primary: themeManager.currentTheme.starPrimary,
                             secondary: themeManager.currentTheme.starSecondary,
                             blur: themeManager.currentTheme.starBlurRadius)
            }
            
            if isToday {
                Circle()
                    .fill(themeManager.currentTheme.todayGlow.opacity(0.3))
                    .frame(width: 35).blur(radius: 10)
            }
            
            Text("\(day)")
                .font(.system(size: 16, weight: isToday ? .black : .light, design: .rounded))
                .foregroundColor(
                    isToday ? themeManager.currentTheme.todayColor :
                    (isFilled ? themeManager.currentTheme.textColor : themeManager.currentTheme.textColor.opacity(themeManager.currentTheme.inactiveOpacity))
                )
                .shadow(color: .black.opacity(isFilled || isToday ? 0.8 : 0), radius: 1)
        }
        .frame(height: 32)
    }
}
