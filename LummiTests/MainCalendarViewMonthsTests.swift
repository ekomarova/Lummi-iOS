import Testing
import Foundation
@testable import Lummi

struct MainCalendarViewMonthsTests {

    private func makeDate(year: Int, month: Int, day: Int = 15) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        return Calendar.current.date(from: components) ?? Date()
    }

    private let now = Date(timeIntervalSince1970: 1_790_000_000)

    @Test func noEntries_showsOnlyCurrentMonth() {
        let months = MainCalendarView.months(firstEntryDate: nil, now: now)
        #expect(months == [now.startOfMonth])
    }

    @Test func recentEntry_startsAtItsMonth() {
        let first = Calendar.current.date(byAdding: .month, value: -3, to: now) ?? now
        let months = MainCalendarView.months(firstEntryDate: first, now: now)
        #expect(months.count == 4)
        #expect(months.first == first.startOfMonth)
        #expect(months.last == now.startOfMonth)
    }

    @Test func entryFrom1990_isClampedToEarliestSupportedMonth() {
        let months = MainCalendarView.months(firstEntryDate: makeDate(year: 1990, month: 1), now: now)
        #expect(months.first == Date.earliestAllowedMonth)
        #expect(months.last == now.startOfMonth)
        #expect(months.count < 24)
    }

    @Test func earliestAllowedMonth_isGregorianJanuary2026_inCurrentTimeZone() {
        var gregorian = Calendar(identifier: .gregorian)
        gregorian.timeZone = .current
        let components = gregorian.dateComponents([.year, .month, .day], from: Date.earliestAllowedMonth)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 1)
    }

    @Test func entryFromTheFuture_stillShowsCurrentMonth() {
        let months = MainCalendarView.months(firstEntryDate: makeDate(year: 2099, month: 1), now: now)
        #expect(months == [now.startOfMonth])
    }
}
