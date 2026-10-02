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
        let result = TrendsCalculator.entries(entries, in: .month, year: 2026, now: now, calendar: calendar)
        #expect(result.count == 2)
    }

    @Test func entriesInRange_month_includesEntriesLaterInTheMonthThanToday() {
        // A `.month` range always spans the whole calendar month, so an entry dated later in the same
        // month than "now" is still included. In practice this never happens: `JoyEntry.date` is always
        // stamped with the current moment at creation (see `JoyEntryStore`), never forward-dated.
        let entries = [entry(year: 2026, month: 9, day: 25)]
        let result = TrendsCalculator.entries(entries, in: .month, year: 2026, now: now, calendar: calendar)
        #expect(result.count == 1)
    }

    @Test func entriesInRange_month_excludesEntriesOutsideTheMonth() {
        let entries = [entry(year: 2026, month: 8, day: 31), entry(year: 2026, month: 10, day: 1)]
        let result = TrendsCalculator.entries(entries, in: .month, year: 2026, now: now, calendar: calendar)
        #expect(result.isEmpty)
    }

    @Test func entriesInRange_year_currentYear_keepsCalendarYearOnly() {
        let entries = [
            entry(year: 2025, month: 12, day: 31), // last day of the previous calendar year
            entry(year: 2026, month: 1, day: 1),   // first day of this calendar year
            entry(year: 2026, month: 9, day: 24)
        ]
        let result = TrendsCalculator.entries(entries, in: .year, year: 2026, now: now, calendar: calendar)
        #expect(result.count == 2)
    }

    @Test func entriesInRange_year_currentYear_includesEntriesLaterInTheYearThanToday() {
        // A `.year` range always spans the whole calendar year, so an entry dated later in the same year
        // than "now" is still included. In practice this never happens: `JoyEntry.date` is always stamped
        // with the current moment at creation (see `JoyEntryStore`), never backdated or forward-dated.
        let entries = [entry(year: 2026, month: 12, day: 25)]
        let result = TrendsCalculator.entries(entries, in: .year, year: 2026, now: now, calendar: calendar)
        #expect(result.count == 1)
    }

    @Test func entriesInRange_year_pastYear_keepsWholeCalendarYear() {
        let entries = [
            entry(year: 2024, month: 12, day: 31), // last day of the year before
            entry(year: 2025, month: 1, day: 1),   // first day of the browsed year
            entry(year: 2025, month: 12, day: 31), // last day of the browsed year
            entry(year: 2026, month: 1, day: 1)    // first day of the year after
        ]
        let result = TrendsCalculator.entries(entries, in: .year, year: 2025, now: now, calendar: calendar)
        #expect(result.count == 2)
    }

    @Test func entriesInRange_year_futureYear_isEmpty() {
        let entries = [entry(year: 2027, month: 1, day: 1)]
        let result = TrendsCalculator.entries(entries, in: .year, year: 2027, now: now, calendar: calendar)
        #expect(result.isEmpty)
    }

    // MARK: - dataPoints(for:range:)

    @Test func dataPoints_month_spansFullMonthIncludingUnreachedDays() {
        // September 2026 has 30 days; "now" is the 24th, so the 25th through the 30th haven't happened
        // yet but still draw as empty bars rather than being left off the chart.
        let entries = [entry(year: 2026, month: 9, day: 1), entry(year: 2026, month: 9, day: 24)]
        let points = TrendsCalculator.dataPoints(for: entries, range: .month, year: 2026, now: now, calendar: calendar)
        #expect(points.count == 30)
        #expect(points.first?.count == 1)
        let lastDayCount = points.last?.count
        #expect(lastDayCount == 0)
        // Every other day is untouched, so the total mass across all bars should equal the two entries.
        #expect(points.map(\.count).reduce(0, +) == 2)
    }

    @Test func dataPoints_month_multipleEntriesSameDay_sumIntoOneBar() {
        let entries = [
            entry(year: 2026, month: 9, day: 10, hour: 9),
            entry(year: 2026, month: 9, day: 10, hour: 20)
        ]
        let points = TrendsCalculator.dataPoints(for: entries, range: .month, year: 2026, now: now, calendar: calendar)
        #expect(points.first { calendar.component(.day, from: $0.periodStart) == 10 }?.count == 2)
    }

    @Test func dataPoints_year_currentYear_spansAllTwelveMonthsIncludingUnreachedOnes() {
        // The chart always draws January through December, even for months later than today (here,
        // October through December), so the month labels never shift as the year progresses.
        let entries = [entry(year: 2026, month: 1, day: 5), entry(year: 2026, month: 9, day: 24)]
        let points = TrendsCalculator.dataPoints(for: entries, range: .year, year: 2026, now: now, calendar: calendar)
        #expect(points.count == 12)
        #expect(points.first?.count == 1) // January
        #expect(points[8].count == 1) // September
        let decemberCount = points.last?.count // unreached, drawn as an empty bar
        #expect(decemberCount == 0)
    }

    @Test func dataPoints_year_pastYear_spansAllTwelveMonths() {
        let entries = [entry(year: 2025, month: 1, day: 5), entry(year: 2025, month: 12, day: 20)]
        let points = TrendsCalculator.dataPoints(for: entries, range: .year, year: 2025, now: now, calendar: calendar)
        #expect(points.count == 12)
        #expect(points.first?.count == 1)
        #expect(points.last?.count == 1)
    }

    @Test func dataPoints_year_currentYear_journalStartedMidYear_stillSpansAllTwelveMonths() {
        // The journal's very first entry ever was in August of this (current) year, so January through
        // July are drawn as empty bars rather than being left off the chart entirely.
        let entries = [entry(year: 2026, month: 8, day: 5)]
        let points = TrendsCalculator.dataPoints(for: entries, range: .year, year: 2026, now: now, calendar: calendar)
        #expect(points.count == 12)
        #expect(points.map(\.count).reduce(0, +) == 1)
        #expect(points[7].count == 1) // August
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

    // MARK: - dateRange

    @Test func dateRange_month_spansTheWholeCurrentMonth() {
        let range = TrendsCalculator.dateRange(for: .month, year: 2026, now: now, calendar: calendar)
        #expect(range?.lowerBound == makeDate(year: 2026, month: 9, day: 1, hour: 0))
        #expect(range?.upperBound == makeDate(year: 2026, month: 10, day: 1, hour: 0))
    }

    @Test func dateRange_month_ignoresTheYearArgument() {
        let range = TrendsCalculator.dateRange(for: .month, year: 2019, now: now, calendar: calendar)
        #expect(range?.lowerBound == makeDate(year: 2026, month: 9, day: 1, hour: 0))
    }

    @Test func dateRange_year_spansAllTwelveMonths() {
        let range = TrendsCalculator.dateRange(for: .year, year: 2025, now: now, calendar: calendar)
        #expect(range?.lowerBound == makeDate(year: 2025, month: 1, day: 1, hour: 0))
        #expect(range?.upperBound == makeDate(year: 2026, month: 1, day: 1, hour: 0))
    }

    @Test func dateRange_currentYear_endsAtTheNextNewYear() {
        let range = TrendsCalculator.dateRange(for: .year, year: 2026, now: now, calendar: calendar)
        #expect(range?.upperBound == makeDate(year: 2027, month: 1, day: 1, hour: 0))
    }

    @Test func dateRange_futureYear_isNil() {
        #expect(TrendsCalculator.dateRange(for: .year, year: 2027, now: now, calendar: calendar) == nil)
    }

    @Test func dateRange_matchesTheEntriesFilter() {
        let entries = [
            entry(year: 2025, month: 12, day: 31, hour: 23),
            entry(year: 2026, month: 1, day: 1, hour: 0),
            entry(year: 2026, month: 12, day: 31, hour: 23),
            entry(year: 2027, month: 1, day: 1, hour: 0)
        ]
        let range = TrendsCalculator.dateRange(for: .year, year: 2026, now: now, calendar: calendar)
        let inRange = entries.filter { range?.contains($0.date) == true }
        #expect(inRange.count == TrendsCalculator.entries(entries, in: .year, year: 2026, now: now, calendar: calendar).count)
        #expect(inRange.count == 2)
    }
}
