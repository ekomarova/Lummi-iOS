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
        let result = TrendsCalculator.entries(entries, in: .month, now: now, oldestEntryDate: nil, calendar: calendar)
        #expect(result.count == 2)
    }

    @Test func entriesInRange_year_keepsCurrentCalendarYearOnly() {
        let entries = [
            entry(year: 2025, month: 12, day: 31), // last day of the previous calendar year
            entry(year: 2026, month: 1, day: 1),   // first day of this calendar year
            entry(year: 2026, month: 9, day: 24)
        ]
        let result = TrendsCalculator.entries(entries, in: .year, now: now, oldestEntryDate: nil, calendar: calendar)
        #expect(result.count == 2)
    }

    @Test func entriesInRange_allTime_noOldestEntry_fallsBackToCurrentMonth() {
        let entries = [entry(year: 2026, month: 1, day: 1)]
        let result = TrendsCalculator.entries(entries, in: .allTime, now: now, oldestEntryDate: nil, calendar: calendar)
        #expect(result.isEmpty)
    }

    @Test func entriesInRange_allTime_startsAtOldestEntrysMonth() {
        let oldest = makeDate(year: 2024, month: 5, day: 10)
        let entries = [
            entry(year: 2024, month: 5, day: 1), // before the oldest entry's day but same month
            entry(year: 2026, month: 9, day: 24)
        ]
        let result = TrendsCalculator.entries(entries, in: .allTime, now: now, oldestEntryDate: oldest, calendar: calendar)
        #expect(result.count == 2)
    }

    @Test func entriesInRange_excludesFutureEntries() {
        let entries = [entry(year: 2026, month: 9, day: 25)]
        let result = TrendsCalculator.entries(entries, in: .month, now: now, oldestEntryDate: nil, calendar: calendar)
        #expect(result.isEmpty)
    }

    // MARK: - dataPoints(for:range:)

    @Test func dataPoints_month_oneBarPerDayUpToToday() {
        let entries = [entry(year: 2026, month: 9, day: 1), entry(year: 2026, month: 9, day: 24)]
        let points = TrendsCalculator.dataPoints(for: entries, range: .month, now: now, oldestEntryDate: nil, calendar: calendar)
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
        let points = TrendsCalculator.dataPoints(for: entries, range: .month, now: now, oldestEntryDate: nil, calendar: calendar)
        #expect(points.first { calendar.component(.day, from: $0.periodStart) == 10 }?.count == 2)
    }

    @Test func dataPoints_year_oneBarPerMonthFromJanuaryToCurrentMonth() {
        let entries = [entry(year: 2026, month: 1, day: 5), entry(year: 2026, month: 9, day: 24)]
        let points = TrendsCalculator.dataPoints(for: entries, range: .year, now: now, oldestEntryDate: nil, calendar: calendar)
        #expect(points.count == 9) // Jan through Sep: the calendar year so far, not 12 months back
        #expect(points.first?.count == 1)
        #expect(points.last?.count == 1)
    }

    @Test func dataPoints_year_journalYoungerThanRange_clampsToOldestEntrysMonth() {
        let oldest = makeDate(year: 2026, month: 8, day: 5)
        let entries = [entry(year: 2026, month: 8, day: 5), entry(year: 2026, month: 9, day: 24)]
        let points = TrendsCalculator.dataPoints(for: entries, range: .year, now: now, oldestEntryDate: oldest, calendar: calendar)
        #expect(points.count == 2) // Aug, Sep
    }

    @Test func dataPoints_allTime_spansFromOldestEntrysMonthToNow() {
        let oldest = makeDate(year: 2026, month: 7, day: 1)
        let entries = [entry(year: 2026, month: 7, day: 1), entry(year: 2026, month: 9, day: 24)]
        let points = TrendsCalculator.dataPoints(for: entries, range: .allTime, now: now, oldestEntryDate: oldest, calendar: calendar)
        #expect(points.count == 3) // Jul, Aug, Sep
    }

    @Test func dataPoints_noOldestEntry_fallsBackToCurrentMonthWithZeroCount() {
        let points = TrendsCalculator.dataPoints(for: [], range: .allTime, now: now, oldestEntryDate: nil, calendar: calendar)
        #expect(points.map(\.count) == [0])
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
}
