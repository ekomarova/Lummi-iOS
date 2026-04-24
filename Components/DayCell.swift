//
//  Calendar Cell
//


import SwiftUI

struct DayCell: View {
    @EnvironmentObject var tm: ThemeManager
    let day: Int
    let isFilled: Bool
    let isToday: Bool
    let isSelected: Bool
    
    private var theme: AppTheme { tm.currentTheme }
    
    var body: some View {
        ZStack {
            if isSelected {
                Circle().fill(theme.textColor.opacity(0.1)).frame(width: 40)
            }
            
            if isFilled {
                NeonStarView(primary: theme.starPrimary,
                             secondary: theme.starSecondary,
                             blur: theme.starBlurRadius)
            }
            
            if isToday {
                Circle()
                    .fill(theme.todayGlow.opacity(0.3))
                    .frame(width: 35).blur(radius: 10)
            }
            
            Text("\(day)")
                .font(.system(size: 16, weight: isToday ? .black : .light, design: .rounded))
                .foregroundColor(
                    isToday ? theme.todayColor :
                    (isFilled ? theme.textColor : theme.textColor.opacity(theme.inactiveOpacity))
                )
                .shadow(color: .black.opacity(isFilled || isToday ? 0.8 : 0), radius: 1)
        }
        .frame(height: 32)
    }
}
