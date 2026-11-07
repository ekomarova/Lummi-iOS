import Testing
import Foundation
@testable import Lummi

@MainActor
struct TrendsPerformanceStatsTests {

    private let calendar = Calendar(identifier: .gregorian)
    private let locale = Locale(identifier: "en_US")

    private func makeDate(year: Int, month: Int, day: Int, hour: Int = 12) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        return calendar.date(from: components) ?? Date()
    }

    private func entry(year: Int, month: Int, day: Int, hour: Int = 12) -> JoyEntry {
        JoyEntry(text: "test", date: makeDate(year: year, month: month, day: day, hour: hour))
    }

    private var now: Date { makeDate(year: 2026, month: 9, day: 24) }

    private func stats(_ entries: [JoyEntry], year: Int) -> TrendsPerformanceStats {
        TrendsPerformanceStats.make(from: entries, year: year, locale: locale, now: now, calendar: calendar)
    }

    @Test func make_emptyEntries_returnsZeroedStats() {
        let result = stats([], year: 2026)
        #expect(result.entryCount == 0)
        #expect(result.daysJournaled == 0)
        #expect(result.bestStreak == 0)
        #expect(result.dataPoints.count == 12)
        #expect(result.dataPoints.reduce(0) { $0 + $1.count } == 0)
        #expect(result.weekdayCounts.reduce(0) { $0 + $1.count } == 0)
    }

    @Test func make_year_countsDaysAndStreakAcrossTheYear() {
        let entries = [
            entry(year: 2025, month: 12, day: 31),
            entry(year: 2026, month: 1, day: 1),
            entry(year: 2026, month: 1, day: 2),
            entry(year: 2026, month: 1, day: 2, hour: 20),
            entry(year: 2026, month: 9, day: 24)
        ]
        let result = stats(entries, year: 2026)
        #expect(result.entryCount == 4)
        #expect(result.daysJournaled == 3)
        #expect(result.bestStreak == 2)
        #expect(result.dataPoints.reduce(0) { $0 + $1.count } == 4)
        #expect(result.weekdayCounts.reduce(0) { $0 + $1.count } == 4)
    }

    @Test func make_year_includesJoyfulHoursAndCountsOnlyThatYear() {
        let entries = [
            entry(year: 2025, month: 12, day: 31),
            entry(year: 2026, month: 1, day: 1),
            entry(year: 2026, month: 9, day: 24)
        ]
        let result = stats(entries, year: 2026)
        #expect(result.entryCount == 2)
        #expect(result.dataPoints.count == 12)
    }

    @Test func make_pastYear_includesJoyfulHours() {
        let result = stats([entry(year: 2025, month: 6, day: 1)], year: 2025)
        #expect(result.entryCount == 1)
        #expect(result.dataPoints.count == 12)
    }

    @Test func make_futureYear_isEmpty() {
        let result = stats([entry(year: 2027, month: 1, day: 1)], year: 2027)
        #expect(result.entryCount == 0)
        #expect(result.dataPoints.isEmpty)
    }

    @Test func make_pastYear_ignoresOtherYears() {
        let entries = [
            entry(year: 2025, month: 6, day: 1),
            entry(year: 2026, month: 6, day: 1)
        ]
        let result = stats(entries, year: 2025)
        #expect(result.entryCount == 1)
    }

    @Test func make_weekdayCounts_followTheGivenCalendarsFirstWeekday() {
        var mondayFirst = calendar
        mondayFirst.firstWeekday = 2 // Monday
        let result = TrendsPerformanceStats.make(
            from: [entry(year: 2026, month: 9, day: 1)],
            year: 2026,
            locale: locale,
            now: now,
            calendar: mondayFirst
        )
        #expect(result.weekdayCounts.first?.weekday == 2) // Monday
        #expect(result.weekdayCounts.last?.weekday == 1) // Sunday wraps to the end
        #expect(result.weekdayCounts.reduce(0) { $0 + $1.count } == 1)
    }

    // The calendar the Trends screen passes: the app's own locale-aware one, not the fixed Gregorian test calendar.
    @Test(arguments: ["ru_RU", "de_DE", "en_US"])
    func make_withLummiCalendar_matchesTheSeparateCalculators(localeIdentifier: String) {
        let locale = Locale(identifier: localeIdentifier)
        let lummi = Calendar.lummiCalendar(locale: locale)
        let entries = (1...24).map { entry(year: 2026, month: 9, day: $0, hour: 8 + $0 % 12) }
            + [entry(year: 2026, month: 1, day: 5), entry(year: 2025, month: 12, day: 31)]
        do {
            let result = TrendsPerformanceStats.make(from: entries, year: 2026, locale: locale, now: now, calendar: lummi)
            let ranged = TrendsCalculator.entries(entries, in: .year(2026), now: now, calendar: lummi)
            #expect(result.entryCount == ranged.count)
            #expect(result.daysJournaled == InsightsCalculator.uniqueDaysCount(in: ranged, calendar: lummi))
            #expect(result.bestStreak == InsightsCalculator.longestStreak(in: ranged, calendar: lummi))
            #expect(result.dataPoints == TrendsCalculator.dataPoints(for: ranged, year: 2026, now: now, calendar: lummi))
            #expect(result.weekdayCounts == TrendsCalculator.weekdayCounts(in: ranged, calendar: lummi))
            #expect(result.weekdayCounts.first?.weekday == lummi.firstWeekday)
            #expect(result.weekdayCounts.reduce(0) { $0 + $1.count } == ranged.count)
        }
    }

    @Test func make_matchesTheSeparateCalculators() {
        let entries = (1...24).map { entry(year: 2026, month: 9, day: $0, hour: 8 + $0 % 12) }
        let result = stats(entries, year: 2026)
        let ranged = TrendsCalculator.entries(entries, in: .year(2026), now: now, calendar: calendar)
        #expect(result.entryCount == ranged.count)
        #expect(result.daysJournaled == InsightsCalculator.uniqueDaysCount(in: ranged))
        #expect(result.bestStreak == InsightsCalculator.longestStreak(in: ranged))
        #expect(result.joyfulHours == InsightsCalculator.joyfulHours(entries: ranged, locale: locale))
        #expect(result.dataPoints == TrendsCalculator.dataPoints(for: ranged, year: 2026, now: now, calendar: calendar))
    }
}
