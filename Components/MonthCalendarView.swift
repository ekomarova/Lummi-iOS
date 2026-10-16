//
//  Required Notice: Copyright Evseniia Komarova (https://github.com/ekomarova)
//
//  Licensed under the PolyForm Noncommercial License 1.0.0.
//  See the LICENSE file in the repository root for full terms.
//  <https://polyformproject.org/licenses/noncommercial/1.0.0>
//

import SwiftUI

// Read-only calendar of the current month on a solid card, without a title: a star over every day that has entries,
// and today in the text color. It draws two weeks at a time; scrolling it pages through the weeks to the end of the month.
struct MonthCalendarView: View {
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.locale) var locale

    let month: Date
    // `dateKey`s of the days that have entries.
    let filledDateKeys: Set<String>

    // Side inset shared by the weekday row and the grid, which narrows the columns and so the whole calendar.
    fileprivate static let gridInset: CGFloat = 28
    private static let visibleWeeks = 2
    private static let rowSpacing: CGFloat = 4

    // Index of the week at the top of the window; it starts on the week of today.
    @State private var topWeek: Int?

    private var calendar: Calendar {
        .lummiCalendar(locale: locale)
    }

    private var windowHeight: CGFloat {
        DayCell.height * CGFloat(Self.visibleWeeks) + Self.rowSpacing * CGFloat(Self.visibleWeeks - 1)
    }

    var body: some View {
        let weeks = CalendarMonthLayout.weeks(inMonth: month, calendar: calendar)

        VStack(spacing: 6) {
            WeekdayHeaderView()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: Self.rowSpacing) {
                    ForEach(weeks.indices, id: \.self) { index in
                        weekRow(weeks[index])
                            .id(index)
                    }
                }
                .scrollTargetLayout()
                .padding(.horizontal, Self.gridInset)
            }
            .scrollTargetBehavior(.viewAligned)
            .scrollPosition(id: $topWeek, anchor: .top)
            .frame(height: windowHeight)
            .accessibilityIdentifier("MonthCalendar")
            .onAppear {
                topWeek = CalendarMonthLayout.weekIndex(of: Date(), inMonth: month, calendar: calendar) ?? 0
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .frame(maxWidth: .infinity)
        .solidCard(RoundedRectangle(cornerRadius: 24))
    }

    private func weekRow(_ week: [Date?]) -> some View {
        HStack(spacing: 7) {
            ForEach(week.indices, id: \.self) { column in
                if let date = week[column] {
                    let dateKey = date.stringKey
                    DayCell(
                        day: calendar.component(.day, from: date),
                        isFilled: filledDateKeys.contains(dateKey),
                        isToday: calendar.isDateInToday(date),
                        dateKey: dateKey
                    )
                    .frame(maxWidth: .infinity)
                } else {
                    Color.clear
                        .frame(maxWidth: .infinity)
                        .frame(height: DayCell.height)
                }
            }
        }
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
        .padding(.horizontal, MonthCalendarView.gridInset)
    }
}

#if DEBUG
#Preview {
    MonthCalendarView(month: Date().startOfMonth, filledDateKeys: [Date().stringKey])
        .padding(.horizontal, 20)
        .previewEnvironment()
}
#endif
