//
//  Copyright (c) 2026, Evseniia Komarova.
//  All rights reserved.
//
//  Licensed under the PolyForm Noncommercial License 1.0.0.
//  See the LICENSE file in the repository root for full terms.
//  <https://polyformproject.org/licenses/noncommercial/1.0.0>
//

import SwiftUI
import SwiftData

// Scrollable month-by-month calendar for picking a day.
struct MainCalendarView: View {
    @Environment(ThemeManager.self) private var themeManager
    @Binding var selectedDate: Date
    @Binding var isCalendarExpanded: Bool
    @Binding var visibleMonth: Date
    
    // Only the oldest entry is needed here (it sets the first month); each month fetches its own entries.
    @Query(JoyEntry.oldestEntryDescriptor) private var oldestEntries: [JoyEntry]
    
    @State private var scrollID: Date?
    
    private var months: [Date] {
        CalendarMonthLayout.monthStarts(firstEntryDate: oldestEntries.first?.date, now: Date())
    }

    var body: some View {
        VStack(spacing: 0) {
            WeekdayHeaderView()
                .padding(.top, 10)
                .padding(.bottom, 10)
            
            // Vertical scroll
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 0) {
                    ForEach(months, id: \.self) { monthDate in
                        SingleMonthView(
                            monthDate: monthDate,
                            selectedDate: $selectedDate,
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
            .onChange(of: scrollID) { _, newValue in
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
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.locale) var locale
    let monthDate: Date
    @Binding var selectedDate: Date
    @Binding var isCalendarExpanded: Bool

    // Entries of this month only; the lazy stack builds just the months near the viewport.
    @Query private var monthEntries: [JoyEntry]
    
    let columns = Array(repeating: GridItem(.flexible(), spacing: 7), count: 7)

    init(monthDate: Date, selectedDate: Binding<Date>, isCalendarExpanded: Binding<Bool>) {
        self.monthDate = monthDate
        _selectedDate = selectedDate
        _isCalendarExpanded = isCalendarExpanded
        _monthEntries = Query(filter: JoyEntry.monthPredicate(for: monthDate))
    }

    private var calendar: Calendar {
        .lummiCalendar(locale: locale)
    }

    private var monthDates: [Date] {
        CalendarMonthLayout.dates(inMonth: monthDate, calendar: calendar)
    }

    private var firstDayOffset: Int {
        CalendarMonthLayout.firstDayOffset(monthDate, calendar: calendar)
    }

    var body: some View {
        // Computed once per render instead of once per day cell
        let filledDates = Set(monthEntries.map(\.dateKey))
        let selectedKey = selectedDate.stringKey

        VStack(spacing: 0) {
            Spacer()
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach((-firstDayOffset)..<0, id: \.self) { _ in
                    Color.clear.frame(height: 38)
                }
                
                ForEach(monthDates, id: \.self) { exactDate in
                    let day = calendar.component(.day, from: exactDate)
                    let dateKey = exactDate.stringKey
                    let isToday = calendar.isDateInToday(exactDate)
                    let isSelected = selectedKey == dateKey
                    
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
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.locale) var locale
    private var weekdayLabels: [String] {
        let calendar = Calendar.lummiCalendar(locale: locale)
        let symbols = calendar.veryShortWeekdaySymbols
        let firstDayIndex = calendar.firstWeekday - 1
        return Array(symbols[firstDayIndex...] + symbols[..<firstDayIndex])
    }

    var body: some View {
        let labels = weekdayLabels
        HStack(spacing: 0) {
            ForEach(labels.indices, id: \.self) { index in
                Text(labels[index])
                    .font(.lummiFont(size: 13))
                    .foregroundColor(themeManager.currentTheme.textColor.opacity(0.4))
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal)
    }
}

#if DEBUG
#Preview {
    MainCalendarView(selectedDate: .constant(Date()), isCalendarExpanded: .constant(true), visibleMonth: .constant(Date().startOfMonth))
        .previewEnvironment()
}
#endif
