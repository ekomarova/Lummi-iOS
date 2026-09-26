import Testing
import Foundation
import os
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

    // MARK: - isCurrentMonth

    @Test func isCurrentMonth_today_returnsTrue() {
        #expect(Date.isCurrentMonth(Date()))
    }

    @Test func isCurrentMonth_distantPastDate_returnsFalse() {
        #expect(!Date.isCurrentMonth(makeDate(year: 2000, month: 1, day: 1)))
    }

    // MARK: - format (shared formatter cache)

    @Test func format_concurrentCalls_returnCorrectResultsWithoutRacing() {
        let date = makeDate(year: 2026, month: 3, day: 5)
        let formats = ["yyyy", "MM", "dd", "yyyy-MM-dd", "LLLL yyyy", "MMM"]
        let locales = [Locale(identifier: "en"), Locale(identifier: "ru"), Locale(identifier: "de")]
        let expectedYear = date.format("yyyy", locale: Locale(identifier: "en"))
        let failures = OSAllocatedUnfairLock(initialState: 0)

        DispatchQueue.concurrentPerform(iterations: 400) { index in
            let text = date.format(formats[index % formats.count], locale: locales[index % locales.count])
            if text.isEmpty { failures.withLock { $0 += 1 } }
            if date.format("yyyy", locale: Locale(identifier: "en")) != expectedYear { failures.withLock { $0 += 1 } }
        }

        #expect(failures.withLock { $0 } == 0)
        #expect(expectedYear == "2026")
    }

    // MARK: - format (cache keying)

    @Test func format_sameFormatDifferentLocales_doesNotReuseFormatterAcrossLocales() {
        let date = makeDate(year: 2026, month: 3, day: 5)
        #expect(date.format("LLLL", locale: Locale(identifier: "en")) == "March")
        #expect(date.format("LLLL", locale: Locale(identifier: "de")) == "März")
        #expect(date.format("LLLL", locale: Locale(identifier: "en")) == "March")
    }

    @Test func format_differentFormatsSameLocale_doesNotReuseFormatterAcrossFormats() {
        let date = makeDate(year: 2026, month: 3, day: 5)
        let locale = Locale(identifier: "en_US_POSIX")
        #expect(date.format("yyyy", locale: locale) == "2026")
        #expect(date.format("MM", locale: locale) == "03")
        #expect(date.format("yyyy", locale: locale) == "2026")
    }

    @Test func format_concurrentCallsWithManyDistinctFormats_stayCorrect() {
        let date = makeDate(year: 2026, month: 3, day: 5)
        let locale = Locale(identifier: "en_US_POSIX")
        let failures = OSAllocatedUnfairLock(initialState: 0)

        // Distinct patterns force concurrent inserts into the cache, not just reads of existing entries.
        DispatchQueue.concurrentPerform(iterations: 200) { index in
            let text = date.format("yyyy'-\(index)'", locale: locale)
            if text != "2026-\(index)" { failures.withLock { $0 += 1 } }
        }

        #expect(failures.withLock { $0 } == 0)
    }
}
