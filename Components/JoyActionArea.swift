import SwiftUI

struct JoyActionArea: View {
    @EnvironmentObject var tm: ThemeManager
    
    let selectedDay: Int?
    let today: Int
    let joyEntries: [Int: String]
    var onTap: () -> Void
    
    private var theme: AppTheme { tm.currentTheme }
    
    var body: some View {
        Group {
            if let selected = selectedDay {
                if selected > today {
                    VStack(spacing: 12) {
                        Image(systemName: "moon.stars.fill")
                            .font(.system(size: 40))
                            .foregroundColor(theme.textColor.opacity(0.2))
                        
                        Text("Oops! This day has not started yet")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(theme.textColor.opacity(0.6))
                        
                        Text("✨ Lumens will light up when the time is right ✨")
                            .font(.system(size: 13))
                            .foregroundColor(theme.textColor.opacity(0.4))
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    
                } else if let note = joyEntries[selected] {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(note)
                            .font(.system(size: 16, weight: .light, design: .rounded))
                            .foregroundColor(theme.textColor)
                            .padding(20)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(theme.textColor.opacity(tm.isDark ? 0.07 : 0.05))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(theme.textColor.opacity(0.1), lineWidth: 1)
                                    )
                            )
                    }
                    .padding(.horizontal)

                } else if selected == today {
                    Button(action: onTap) {
                        HStack(spacing: 12) {
                            Image(systemName: "sparkles")
                            Text("Record the joy")
                        }
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(tm.isDark ? .black : .white)
                        .padding(.vertical, 18)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(theme.todayColor)
                                .shadow(color: theme.todayColor.opacity(tm.isDark ? 0.5 : 0.2), radius: 15)
                        )
                    }
                    .padding(.horizontal)
                    
                } else {
                    Text("No records for this day")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(theme.textColor.opacity(0.3))
                }
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: selectedDay)
    }
}
