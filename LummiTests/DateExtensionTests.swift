import Testing
import Foundation
@testable import Lummi

struct DateExtensionTests {

    private func makeDate(year: Int, month: Int, day: Int, hour: Int = 0) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        return Calendar.current.date(from: components) ?? Date()
    }

    // MARK: - stringKey

    @Test func stringKey_formatsAsISO8601Date() {
        #expect(makeDate(year: 2026, month: 3, day: 5).stringKey == "2026-03-05")
    }

    @Test func stringKey_singleDigitMonthAndDay_padsWithZero() {
        #expect(makeDate(year: 2026, month: 1, day: 7).stringKey == "2026-01-07")
    }

    // MARK: - format

    @Test func format_customPattern_returnsFormattedString() {
        let result = makeDate(year: 2026, month: 3, day: 5).format("yyyy/MM/dd", locale: Locale(identifier: "en_US_POSIX"))
        #expect(result == "2026/03/05")
    }

    @Test func format_calledTwiceWithSamePattern_returnsSameResult() {
        let date = makeDate(year: 2026, month: 3, day: 5)
        let first  = date.format("dd.MM.yyyy", locale: Locale(identifier: "en_US_POSIX"))
        let second = date.format("dd.MM.yyyy", locale: Locale(identifier: "en_US_POSIX"))
        #expect(first == "05.03.2026")
        #expect(first == second)
    }

    // MARK: - startOfMonth

    @Test func startOfMonth_midMonthDate_returnsFirstDayAtMidnight() {
        let start = makeDate(year: 2026, month: 3, day: 17, hour: 15).startOfMonth
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: start)
        #expect(components.year == 2026)
        #expect(components.month == 3)
        #expect(components.day == 1)
        #expect(components.hour == 0)
        #expect(components.minute == 0)
    }

    // MARK: - previousMonth

    @Test func previousMonth_january_returnsDecemberOfPreviousYear() {
        let prev = makeDate(year: 2026, month: 1, day: 15).previousMonth()
        let components = Calendar.current.dateComponents([.year, .month], from: prev)
        #expect(components.year == 2025)
        #expect(components.month == 12)
    }

    @Test func previousMonth_march_returnsFebruary() {
        let prev = makeDate(year: 2026, month: 3, day: 31).previousMonth()
        let components = Calendar.current.dateComponents([.year, .month], from: prev)
        #expect(components.year == 2026)
        #expect(components.month == 2)
    }

    // MARK: - isCurrentMonth

    @Test func isCurrentMonth_today_returnsTrue() {
        #expect(Date.isCurrentMonth(Date()))
    }

    @Test func isCurrentMonth_distantPastDate_returnsFalse() {
        #expect(!Date.isCurrentMonth(makeDate(year: 2000, month: 1, day: 1)))
    }

    // MARK: - isOldestMonth

    @Test func isOldestMonth_noOldestEntry_returnsTrue() {
        #expect(Date.isOldestMonth(selectedMonth: Date(), oldestEntryDate: nil))
    }

    @Test func isOldestMonth_selectedBeforeOldestEntry_returnsTrue() {
        let selected = makeDate(year: 2026, month: 1, day: 1)
        #expect(Date.isOldestMonth(selectedMonth: selected, oldestEntryDate: makeDate(year: 2026, month: 3, day: 10)))
    }

    @Test func isOldestMonth_selectedAtSameMonthAsOldest_returnsTrue() {
        let selected = makeDate(year: 2026, month: 3, day: 1)
        #expect(Date.isOldestMonth(selectedMonth: selected, oldestEntryDate: makeDate(year: 2026, month: 3, day: 10)))
    }

    @Test func isOldestMonth_selectedAfterOldestEntry_returnsFalse() {
        let selected = makeDate(year: 2026, month: 6, day: 1)
        #expect(!Date.isOldestMonth(selectedMonth: selected, oldestEntryDate: makeDate(year: 2026, month: 3, day: 10)))
    }
}
