import SwiftUI

struct MainCalendarView: View {
    @ObservedObject var themeManager: ThemeManager
    @Binding var selectedDay: Int?
    @Binding var joyEntries: [Int: String]
    
    private let calendar = Calendar.current
    private let now = Date()
    let columns = Array(repeating: GridItem(.flexible(), spacing: 7), count: 7)
    
    var daysInMonth: Int { calendar.range(of: .day, in: .month, for: now)?.count ?? 31 }
    var today: Int { calendar.component(.day, from: now) }
    
    var firstDayOffset: Int {
        let components = calendar.dateComponents([.year, .month], from: now)
        guard let firstDayOfMonth = calendar.date(from: components) else { return 0 }
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        let firstDayOfWeek = calendar.firstWeekday
        return (firstWeekday - firstDayOfWeek + 7) % 7
    }

    var weekdayLabels: [String] {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        let symbols = formatter.veryShortWeekdaySymbols ?? []
        let firstDayIndex = calendar.firstWeekday - 1
        return Array(symbols[firstDayIndex...] + symbols[..<firstDayIndex])
    }

    var body: some View {
        VStack(spacing: 15) {
            HStack(spacing: 0) {
                ForEach(weekdayLabels.indices, id: \.self) { index in
                    Text(weekdayLabels[index])
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(themeManager.currentTheme.textColor.opacity(0.4))
                        .frame(maxWidth: .infinity)
                }
            }

            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(0..<firstDayOffset, id: \.self) { index in
                    Color.clear
                        .frame(height: 28)
                        .id("empty-\(index)")
                }
                
                ForEach(1...daysInMonth, id: \.self) { day in
                    DayCell(
                        day: day,
                        isFilled: joyEntries.keys.contains(day),
                        isToday: day == today,
                        isSelected: day == selectedDay
                    )
                    .id("day-\(day)")
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            selectedDay = day
                        }
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}
