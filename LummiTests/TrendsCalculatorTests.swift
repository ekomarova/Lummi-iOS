import Testing
import Foundation
@testable import Lummi

struct TrendsCalculatorTests {

    private let calendar = Calendar(identifier: .gregorian)

    private func makeDate(year: Int, month: Int, day: Int, hour: Int = 12) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        return calendar.date(from: components) ?? Date()
    }

    private func entry(_ text: String = "test", year: Int, month: Int, day: Int, hour: Int = 12) -> JoyEntry {
        JoyEntry(text: text, date: makeDate(year: year, month: month, day: day, hour: hour))
    }

    private var now: Date { makeDate(year: 2026, month: 9, day: 24) }

    // MARK: - entries(in:)

    @Test func entriesInRange_month_keepsOnlyCurrentMonth() {
        let entries = [
            entry(year: 2026, month: 8, day: 31),
            entry(year: 2026, month: 9, day: 1),
            entry(year: 2026, month: 9, day: 24)
        ]
        let result = TrendsCalculator.entries(entries, in: .month, year: 2026, oldestEntryDate: nil, now: now, calendar: calendar)
        #expect(result.count == 2)
    }

    @Test func entriesInRange_excludesFutureEntries() {
        let entries = [entry(year: 2026, month: 9, day: 25)]
        let result = TrendsCalculator.entries(entries, in: .month, year: 2026, oldestEntryDate: nil, now: now, calendar: calendar)
        #expect(result.isEmpty)
    }

    @Test func entriesInRange_year_currentYear_keepsCalendarYearOnly() {
        let entries = [
            entry(year: 2025, month: 12, day: 31), // last day of the previous calendar year
            entry(year: 2026, month: 1, day: 1),   // first day of this calendar year
            entry(year: 2026, month: 9, day: 24)
        ]
        let oldest = makeDate(year: 2025, month: 12, day: 31)
        let result = TrendsCalculator.entries(entries, in: .year, year: 2026, oldestEntryDate: oldest, now: now, calendar: calendar)
        #expect(result.count == 2)
    }

    @Test func entriesInRange_year_currentYear_excludesEntriesAfterToday() {
        let entries = [entry(year: 2026, month: 12, day: 25)] // this calendar year, but in the future
        let result = TrendsCalculator.entries(entries, in: .year, year: 2026, oldestEntryDate: nil, now: now, calendar: calendar)
        #expect(result.isEmpty)
    }

    @Test func entriesInRange_year_pastYear_keepsWholeCalendarYear() {
        let entries = [
            entry(year: 2024, month: 12, day: 31), // last day of the year before
            entry(year: 2025, month: 1, day: 1),   // first day of the browsed year
            entry(year: 2025, month: 12, day: 31), // last day of the browsed year
            entry(year: 2026, month: 1, day: 1)    // first day of the year after
        ]
        let oldest = makeDate(year: 2024, month: 12, day: 31)
        let result = TrendsCalculator.entries(entries, in: .year, year: 2025, oldestEntryDate: oldest, now: now, calendar: calendar)
        #expect(result.count == 2)
    }

    @Test func entriesInRange_year_futureYear_isEmpty() {
        let entries = [entry(year: 2027, month: 1, day: 1)]
        let result = TrendsCalculator.entries(entries, in: .year, year: 2027, oldestEntryDate: nil, now: now, calendar: calendar)
        #expect(result.isEmpty)
    }

    // MARK: - dataPoints(for:range:)

    @Test func dataPoints_month_oneBarPerDayUpToToday() {
        let entries = [entry(year: 2026, month: 9, day: 1), entry(year: 2026, month: 9, day: 24)]
        let points = TrendsCalculator.dataPoints(
            for: entries, range: .month, year: 2026, oldestEntryDate: nil, now: now, calendar: calendar
        )
        #expect(points.count == 24)
        #expect(points.first?.count == 1)
        #expect(points.last?.count == 1)
        // Every other day is untouched, so the total mass across all bars should equal the two entries.
        #expect(points.map(\.count).reduce(0, +) == 2)
    }

    @Test func dataPoints_month_multipleEntriesSameDay_sumIntoOneBar() {
        let entries = [
            entry(year: 2026, month: 9, day: 10, hour: 9),
            entry(year: 2026, month: 9, day: 10, hour: 20)
        ]
        let points = TrendsCalculator.dataPoints(
            for: entries, range: .month, year: 2026, oldestEntryDate: nil, now: now, calendar: calendar
        )
        #expect(points.first { calendar.component(.day, from: $0.periodStart) == 10 }?.count == 2)
    }

    @Test func dataPoints_year_currentYear_noOldestEntry_oneBarPerMonthFromJanuaryToToday() {
        // No oldest entry to clamp against (e.g. `rangedEntries` only, not the journal's true first entry):
        // falls back to showing the whole year-to-date, same as before there was a clamp to opt out of.
        let entries = [entry(year: 2026, month: 1, day: 5), entry(year: 2026, month: 9, day: 24)]
        let points = TrendsCalculator.dataPoints(
            for: entries, range: .year, year: 2026, oldestEntryDate: nil, now: now, calendar: calendar
        )
        #expect(points.count == 9) // Jan through Sep: the calendar year so far, never into the future
        #expect(points.first?.count == 1)
        #expect(points.last?.count == 1)
    }

    @Test func dataPoints_year_pastYear_spansAllTwelveMonths() {
        let entries = [entry(year: 2025, month: 1, day: 5), entry(year: 2025, month: 12, day: 20)]
        let oldest = makeDate(year: 2025, month: 1, day: 5)
        let points = TrendsCalculator.dataPoints(
            for: entries, range: .year, year: 2025, oldestEntryDate: oldest, now: now, calendar: calendar
        )
        #expect(points.count == 12)
        #expect(points.first?.count == 1)
        #expect(points.last?.count == 1)
    }

    @Test func dataPoints_year_currentYear_journalStartedMidYear_clampsToFirstEntrysMonth() {
        // The journal's very first entry ever was in August of this (current) year, so January through
        // July never happened for it and should not be drawn as empty bars.
        let oldest = makeDate(year: 2026, month: 8, day: 5)
        let entries = [entry(year: 2026, month: 8, day: 5)]
        let points = TrendsCalculator.dataPoints(
            for: entries, range: .year, year: 2026, oldestEntryDate: oldest, now: now, calendar: calendar
        )
        #expect(points.count == 2) // Aug, Sep only
        #expect(points.map(\.count).reduce(0, +) == 1)
    }

    @Test func dataPoints_year_pastYear_journalStartedMidThatYear_doesNotClamp() {
        // The clamp only applies to the current, in-progress year: a past year is already fully over, so
        // it always draws its complete twelve months regardless of when the journal's first entry landed.
        let oldest = makeDate(year: 2025, month: 8, day: 5)
        let entries = [entry(year: 2025, month: 8, day: 5)]
        let points = TrendsCalculator.dataPoints(
            for: entries, range: .year, year: 2025, oldestEntryDate: oldest, now: now, calendar: calendar
        )
        #expect(points.count == 12)
    }

    @Test func dataPoints_year_currentYear_oldestEntryFromAnEarlierYear_doesNotClamp() {
        // The oldest entry predates this year entirely, so it never raises the start above January 1st.
        let oldest = makeDate(year: 2024, month: 3, day: 1)
        let entries = [entry(year: 2026, month: 9, day: 24)]
        let points = TrendsCalculator.dataPoints(
            for: entries, range: .year, year: 2026, oldestEntryDate: oldest, now: now, calendar: calendar
        )
        #expect(points.count == 9) // Jan through Sep
    }

    // MARK: - weekdayCounts

    @Test func weekdayCounts_returnsSevenEntriesStartingAtCalendarsFirstWeekday() {
        var mondayFirst = calendar
        mondayFirst.firstWeekday = 2 // Monday
        let counts = TrendsCalculator.weekdayCounts(in: [], calendar: mondayFirst)
        #expect(counts.count == 7)
        #expect(counts.first?.weekday == 2) // Monday
        #expect(counts.last?.weekday == 1) // Sunday wraps to the end
    }

    @Test func weekdayCounts_countsEntriesOnTheSameWeekday() {
        // 2026-09-21 and 2026-09-28 are both Mondays.
        let entries = [
            entry(year: 2026, month: 9, day: 21),
            entry(year: 2026, month: 9, day: 28)
        ]
        let counts = TrendsCalculator.weekdayCounts(in: entries, calendar: calendar)
        let monday = counts.first { $0.weekday == 2 }
        #expect(monday?.count == 2)
    }

    // MARK: - availableYears

    @Test func availableYears_noOldestEntry_returnsJustTheCurrentYear() {
        let years = TrendsCalculator.availableYears(oldestEntryDate: nil, now: now, calendar: calendar)
        #expect(years == [2026])
    }

    @Test func availableYears_spansOldestEntrysYearThroughCurrentYear_newestFirst() {
        let oldest = makeDate(year: 2023, month: 6, day: 1)
        let years = TrendsCalculator.availableYears(oldestEntryDate: oldest, now: now, calendar: calendar)
        #expect(years == [2026, 2025, 2024, 2023])
    }

    @Test func availableYears_oldestEntryThisYear_returnsOneYear() {
        let oldest = makeDate(year: 2026, month: 3, day: 1)
        let years = TrendsCalculator.availableYears(oldestEntryDate: oldest, now: now, calendar: calendar)
        #expect(years == [2026])
    }
}
