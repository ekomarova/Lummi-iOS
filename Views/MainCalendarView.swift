//
//  Copyright (c) 2026, Evseniia Komarova.
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//  - Redistributions of source code must retain the above copyright notice,
//    this list of conditions and the following disclaimer.
//  - Redistributions in binary form must reproduce the above copyright notice,
//    this list of conditions and the following disclaimer in the documentation
//    and/or other materials provided with the distribution.
//  - Neither the name of the copyright holder nor the names of its contributors
//    may be used to endorse or promote products derived from this software
//    without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
//  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
//  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
//  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
//  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
//  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
//  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
//  THE POSSIBILITY OF SUCH DAMAGE.
//

import SwiftUI
import SwiftData

struct MainCalendarView: View {
    @Environment(ThemeManager.self) private var themeManager
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
            WeekdayHeaderView()
                .padding(.top, AdaptiveLayout.getSize(for: 10))
                .padding(.bottom, AdaptiveLayout.getSize(for: 10))
            
            // Vertical scroll
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 0) {
                    ForEach(months, id: \.self) { monthDate in
                        SingleMonthView(
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
    let monthDate: Date
    @Binding var selectedDate: Date?
    @Binding var isCalendarExpanded: Bool
    
    let filledDates: Set<String>
    
    private let calendar = Calendar.current
    let columns = Array(repeating: GridItem(.flexible(), spacing: AdaptiveLayout.getSize(for: 7)), count: 7)
    
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
            LazyVGrid(columns: columns, spacing: AdaptiveLayout.getSize(for: 4)) {
                ForEach((-firstDayOffset)..<0, id: \.self) { _ in
                    Color.clear.frame(height: AdaptiveLayout.getSize(for: 38))
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
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.locale) var locale
    private var weekdayLabels: [String] {
        var calendar = Calendar.current
        calendar.locale = locale
        let symbols = calendar.veryShortWeekdaySymbols
        let firstDayIndex = calendar.firstWeekday - 1
        return Array(symbols[firstDayIndex...] + symbols[..<firstDayIndex])
    }

    var body: some View {
        let labels = weekdayLabels
        HStack(spacing: 0) {
            ForEach(labels.indices, id: \.self) { index in
                Text(labels[index])
                    .textCase(.uppercase)
                    .font(.lummiFont(size: 13))
                    .foregroundColor(themeManager.currentTheme.calendarContentColor.opacity(0.4))
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal)
    }
}
