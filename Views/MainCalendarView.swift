import SwiftUI

struct MainCalendarView: View {
    @ObservedObject var themeManager: ThemeManager
    @Binding var selectedDate: Date?
    @Binding var joyEntries: [String: [String]]
    @Binding var isCalendarExpanded: Bool
    @Binding var visibleMonth: Date
    
    @State private var scrollID: Date?
    
    private var months: [Date] {
        let calendar = Calendar.current
        let today = Date()
        let currentMonthStart = today.startOfMonth
        
        // 1. Find the earliest entry in the dictionary
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        let entryDates = joyEntries.keys.compactMap { formatter.date(from: $0) }
        
        // 2. Defining the initial month
        // If there are no records, start with the current month
        // If there is, take the earliest date and get the beginning of its month
        let firstEntryDate = entryDates.min() ?? today
        let startMonth = firstEntryDate.startOfMonth
        
        // 3. Generate array from the earliest record up to and including the current month
        var result: [Date] = []
        var iterator = startMonth
        
        while iterator <= currentMonthStart {
            result.append(iterator)
            guard let nextMonth = calendar.date(byAdding: .month, value: 1, to: iterator) else { break }
            iterator = nextMonth
        }
        
        return result
    }


    var body: some View {
        VStack(spacing: 0) {
            WeekdayHeaderView(themeManager: themeManager)
                .padding(.top, 10)
                .padding(.bottom, 10)
            
            // Vertical scroll
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 0) {
                    ForEach(months, id: \.self) { monthDate in
                        SingleMonthView(
                            themeManager: themeManager,
                            monthDate: monthDate,
                            selectedDate: $selectedDate,
                            joyEntries: $joyEntries,
                            isCalendarExpanded: $isCalendarExpanded
                        )
                        .containerRelativeFrame(.vertical, alignment: .top)
                        .id(monthDate)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.paging)
            .scrollPosition(id: $scrollID)
            .onChange(of: scrollID) { oldValue, newValue in
                if let newMonth = newValue {
                    visibleMonth = newMonth
                }
            }
            .onAppear {
                scrollID = months.contains(visibleMonth) ? visibleMonth : months.last
            }
        }
    }
}

// MARK: - Single Month View

struct SingleMonthView: View {
    @ObservedObject var themeManager: ThemeManager
    let monthDate: Date
    @Binding var selectedDate: Date?
    @Binding var joyEntries: [String: [String]]
    @Binding var isCalendarExpanded: Bool
    
    private let calendar = Calendar.current
    let columns = Array(repeating: GridItem(.flexible(), spacing: 7), count: 7)
    
    var daysInMonth: Int { calendar.range(of: .day, in: .month, for: monthDate)?.count ?? 31 }
    
    var firstDayOffset: Int {
        let firstWeekday = calendar.component(.weekday, from: monthDate)
        let firstDayOfWeek = calendar.firstWeekday
        return (firstWeekday - firstDayOfWeek + 7) % 7
    }
    
    private func dateFor(day: Int) -> Date {
        var components = calendar.dateComponents([.year, .month], from: monthDate)
        components.day = day
        return calendar.date(from: components) ?? Date()
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach((-firstDayOffset)..<0, id: \.self) { index in
                    Color.clear.frame(height: 38)
                }
                
                ForEach(1...daysInMonth, id: \.self) { day in
                    let exactDate = dateFor(day: day)
                    let dateKey = exactDate.stringKey
                    let isToday = calendar.isDateInToday(exactDate)
                    let isSelected = selectedDate?.stringKey == dateKey
                    
                    DayCell(
                        day: day,
                        isFilled: joyEntries[dateKey]?.isEmpty == false,
                        isToday: isToday,
                        isSelected: isSelected
                    )
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                            selectedDate = exactDate
                            isCalendarExpanded = false
                        }
                    }
                }
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal)
    }
}

// MARK: - Weekday Header View

struct WeekdayHeaderView: View {
    @ObservedObject var themeManager: ThemeManager
    private let weekdayLabels: [String] = {
        let symbols = DateFormatter().veryShortWeekdaySymbols ?? []
        let firstDayIndex = Calendar.current.firstWeekday - 1
        return Array(symbols[firstDayIndex...] + symbols[..<firstDayIndex])
    }()
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(weekdayLabels.indices, id: \.self) { index in
                Text(weekdayLabels[index])
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(themeManager.currentTheme.calendarContentColor.opacity(0.4))
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal)
    }
}
