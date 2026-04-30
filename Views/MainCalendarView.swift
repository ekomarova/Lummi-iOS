import SwiftUI
import SwiftData

struct MainCalendarView: View {
    @ObservedObject var themeManager: ThemeManager
    @Binding var selectedDate: Date?
    @Binding var isCalendarExpanded: Bool
    @Binding var visibleMonth: Date
    
    @Query(sort: \JoyEntry.date, order: .forward) private var allEntries: [JoyEntry]
    
    @State private var scrollID: Date?
    
    // Search for days with stars
    private var filledDateKeys: Set<String> {
        Set(allEntries.map { $0.dateKey })
    }
    
    private var months: [Date] {
        let calendar = Calendar.current
        let today = Date()
        let currentMonthStart = today.startOfMonth
        
        // Defining the initial month
        // If there are no records, start with the current month
        // If there is, take the earliest date and get the beginning of its month
        let firstEntryDate = allEntries.first?.date ?? today
        let startMonth = firstEntryDate.startOfMonth
        
        // Generate array from the earliest record up to and including the current month
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
                            isCalendarExpanded: $isCalendarExpanded,
                            filledDates: filledDateKeys
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
    @Binding var isCalendarExpanded: Bool
    
    let filledDates: Set<String>
    
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
                        isFilled: filledDates.contains(dateKey),
                        isToday: isToday,
                        isSelected: isSelected,
                        dateKey: dateKey
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
                    .font(.lummiFont(size: 13))
                    .foregroundColor(themeManager.currentTheme.calendarContentColor.opacity(0.4))
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal)
    }
}
