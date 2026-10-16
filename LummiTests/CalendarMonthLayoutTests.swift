import Testing
import Foundation
@testable import Lummi

struct CalendarMonthLayoutTests {

    private func makeCalendar(firstWeekday: Int) -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .current
        calendar.firstWeekday = firstWeekday
        return calendar
    }

    private func makeDate(_ year: Int, _ month: Int, _ day: Int, calendar: Calendar) -> Date {
        let components = DateComponents(year: year, month: month, day: day, hour: 12)
        return calendar.date(from: components) ?? Date.distantPast
    }

    // MARK: - daysInMonth

    @Test func daysInMonth_regularMonths() {
        let cal = makeCalendar(firstWeekday: 1)
        #expect(CalendarMonthLayout.daysInMonth(makeDate(2026, 1, 15, calendar: cal), calendar: cal) == 31)
        #expect(CalendarMonthLayout.daysInMonth(makeDate(2026, 4, 1, calendar: cal), calendar: cal) == 30)
    }

    @Test func daysInMonth_february_leapAndNonLeap() {
        let cal = makeCalendar(firstWeekday: 1)
        #expect(CalendarMonthLayout.daysInMonth(makeDate(2026, 2, 10, calendar: cal), calendar: cal) == 28)
        #expect(CalendarMonthLayout.daysInMonth(makeDate(2028, 2, 10, calendar: cal), calendar: cal) == 29)
    }

    // MARK: - firstDayOffset

    @Test func firstDayOffset_sundayFirst() {
        let cal = makeCalendar(firstWeekday: 1)
        // 1 Feb 2026 is a Sunday, 1 Mar 2026 is a Sunday, 1 Apr 2026 is a Wednesday
        #expect(CalendarMonthLayout.firstDayOffset(makeDate(2026, 2, 1, calendar: cal), calendar: cal) == 0)
        #expect(CalendarMonthLayout.firstDayOffset(makeDate(2026, 4, 1, calendar: cal), calendar: cal) == 3)
    }

    @Test func firstDayOffset_mondayFirst() {
        let cal = makeCalendar(firstWeekday: 2)
        #expect(CalendarMonthLayout.firstDayOffset(makeDate(2026, 2, 1, calendar: cal), calendar: cal) == 6)
        #expect(CalendarMonthLayout.firstDayOffset(makeDate(2026, 4, 1, calendar: cal), calendar: cal) == 2)
    }

    @Test func firstDayOffset_midMonthDate_usesFirstOfMonth() {
        let cal = makeCalendar(firstWeekday: 1)
        #expect(CalendarMonthLayout.firstDayOffset(makeDate(2026, 4, 20, calendar: cal), calendar: cal) == 3)
    }

    // MARK: - date(forDay:inMonth:)

    @Test func dateForDay_validDay_returnsThatDay() {
        let cal = makeCalendar(firstWeekday: 1)
        let result = CalendarMonthLayout.date(forDay: 15, inMonth: makeDate(2026, 3, 1, calendar: cal), calendar: cal)
        let components = result.map { cal.dateComponents([.year, .month, .day], from: $0) }
        #expect(components == DateComponents(year: 2026, month: 3, day: 15))
    }

    // MARK: - dates(inMonth:)

    @Test func datesInMonth_countMatchesDaysAndIsOrdered() {
        let cal = makeCalendar(firstWeekday: 1)
        let dates = CalendarMonthLayout.dates(inMonth: makeDate(2028, 2, 1, calendar: cal), calendar: cal)
        #expect(dates.count == 29)
        #expect(dates == dates.sorted())
        #expect(cal.component(.day, from: dates[28]) == 29)
    }

    // MARK: - weeks(inMonth:)

    @Test func weeks_everyRowHasSevenCells() {
        let cal = makeCalendar(firstWeekday: 1)
        let weeks = CalendarMonthLayout.weeks(inMonth: makeDate(2026, 4, 1, calendar: cal), calendar: cal)
        #expect(weeks.count == 5)
        #expect(weeks.allSatisfy { $0.count == 7 })
    }

    @Test func weeks_leadingAndTrailingCellsAreEmpty() {
        let cal = makeCalendar(firstWeekday: 1)
        // April 2026 starts on a Wednesday and ends on a Thursday
        let weeks = CalendarMonthLayout.weeks(inMonth: makeDate(2026, 4, 1, calendar: cal), calendar: cal)
        #expect(weeks[0].prefix(3).allSatisfy { $0 == nil })
        #expect(weeks[0][3] != nil)
        #expect(weeks[4][4] != nil)
        #expect(weeks[4].suffix(2).allSatisfy { $0 == nil })
        #expect(weeks.flatMap { $0 }.compactMap { $0 }.count == 30)
    }

    @Test func weeks_februaryStartingOnFirstWeekday_isFourFullRows() {
        let cal = makeCalendar(firstWeekday: 1)
        let weeks = CalendarMonthLayout.weeks(inMonth: makeDate(2026, 2, 1, calendar: cal), calendar: cal)
        #expect(weeks.count == 4)
        #expect(weeks.flatMap { $0 }.allSatisfy { $0 != nil })
    }

    @Test func weeks_monthSpanningSixRows() {
        let cal = makeCalendar(firstWeekday: 1)
        // August 2026 starts on a Saturday and has 31 days
        let weeks = CalendarMonthLayout.weeks(inMonth: makeDate(2026, 8, 1, calendar: cal), calendar: cal)
        #expect(weeks.count == 6)
    }

    @Test func weeks_followTheCalendarsFirstWeekday() {
        let mondayFirst = makeCalendar(firstWeekday: 2)
        // April 2026 starts on a Wednesday: two empty cells when the week starts on Monday
        let weeks = CalendarMonthLayout.weeks(inMonth: makeDate(2026, 4, 1, calendar: mondayFirst), calendar: mondayFirst)
        #expect(weeks[0].prefix(2).allSatisfy { $0 == nil })
        #expect(weeks[0][2] != nil)
    }

    // MARK: - weekIndex(of:inMonth:)

    @Test func weekIndex_findsTheRowOfADay() {
        let cal = makeCalendar(firstWeekday: 1)
        let month = makeDate(2026, 4, 1, calendar: cal)
        #expect(CalendarMonthLayout.weekIndex(of: makeDate(2026, 4, 1, calendar: cal), inMonth: month, calendar: cal) == 0)
        #expect(CalendarMonthLayout.weekIndex(of: makeDate(2026, 4, 5, calendar: cal), inMonth: month, calendar: cal) == 1)
        #expect(CalendarMonthLayout.weekIndex(of: makeDate(2026, 4, 30, calendar: cal), inMonth: month, calendar: cal) == 4)
    }

    @Test func weekIndex_dayOutsideTheMonth_isNil() {
        let cal = makeCalendar(firstWeekday: 1)
        let month = makeDate(2026, 4, 1, calendar: cal)
        #expect(CalendarMonthLayout.weekIndex(of: makeDate(2026, 5, 1, calendar: cal), inMonth: month, calendar: cal) == nil)
    }
}
