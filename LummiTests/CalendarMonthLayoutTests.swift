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

    // MARK: - monthStarts

    @Test func monthStarts_noEntries_returnsCurrentMonthOnly() {
        let cal = makeCalendar(firstWeekday: 1)
        let now = makeDate(2026, 3, 20, calendar: cal)
        let result = CalendarMonthLayout.monthStarts(firstEntryDate: nil, now: now, calendar: cal)
        #expect(result.count == 1)
        #expect(cal.component(.month, from: result[0]) == 3)
        #expect(cal.component(.day, from: result[0]) == 1)
    }

    @Test func monthStarts_spansYearBoundary() {
        let cal = makeCalendar(firstWeekday: 1)
        let result = CalendarMonthLayout.monthStarts(
            firstEntryDate: makeDate(2025, 11, 18, calendar: cal),
            now: makeDate(2026, 2, 3, calendar: cal),
            calendar: cal
        )
        #expect(result.count == 4)
        #expect(cal.component(.month, from: result[0]) == 11)
        #expect(cal.component(.year, from: result[3]) == 2026)
    }

    @Test func monthStarts_entryInFuture_returnsEmpty() {
        let cal = makeCalendar(firstWeekday: 1)
        let result = CalendarMonthLayout.monthStarts(
            firstEntryDate: makeDate(2026, 6, 1, calendar: cal),
            now: makeDate(2026, 3, 1, calendar: cal),
            calendar: cal
        )
        #expect(result.isEmpty)
    }
}
