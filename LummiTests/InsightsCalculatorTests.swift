import Testing
import Foundation
@testable import Lummi

struct InsightsCalculatorTests {

    private func makeDate(year: Int, month: Int, day: Int, hour: Int = 12) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        return Calendar.current.date(from: components) ?? Date()
    }

    private func entry(_ text: String = "test", year: Int, month: Int, day: Int, hour: Int = 12) -> JoyEntry {
        JoyEntry(text: text, date: makeDate(year: year, month: month, day: day, hour: hour))
    }

    // MARK: - uniqueDaysCount

    @Test func uniqueDaysCount_emptyList_returnsZero() {
        #expect(InsightsCalculator.uniqueDaysCount(in: []) == 0)
    }

    @Test func uniqueDaysCount_multipleEntriesSameDay_countsAsOne() {
        let entries = [
            entry(year: 2026, month: 1, day: 5, hour: 9),
            entry(year: 2026, month: 1, day: 5, hour: 14),
            entry(year: 2026, month: 1, day: 5, hour: 20)
        ]
        #expect(InsightsCalculator.uniqueDaysCount(in: entries) == 1)
    }

    @Test func uniqueDaysCount_differentDays_countsAll() {
        let entries = [
            entry(year: 2026, month: 1, day: 1),
            entry(year: 2026, month: 1, day: 2),
            entry(year: 2026, month: 1, day: 3)
        ]
        #expect(InsightsCalculator.uniqueDaysCount(in: entries) == 3)
    }

    @Test func uniqueDaysCount_entriesInDifferentYears_countsBoth() {
        let entries = [
            entry(year: 2025, month: 1, day: 1),
            entry(year: 2026, month: 1, day: 1)
        ]
        #expect(InsightsCalculator.uniqueDaysCount(in: entries) == 2)
    }

    // MARK: - longestStreak

    @Test func longestStreak_emptyList_returnsZero() {
        #expect(InsightsCalculator.longestStreak(in: []) == 0)
    }

    @Test func longestStreak_singleEntry_returnsOne() {
        #expect(InsightsCalculator.longestStreak(in: [entry(year: 2026, month: 1, day: 1)]) == 1)
    }

    @Test func longestStreak_threeConsecutiveDays_returnsThree() {
        let entries = [
            entry(year: 2026, month: 1, day: 1),
            entry(year: 2026, month: 1, day: 2),
            entry(year: 2026, month: 1, day: 3)
        ]
        #expect(InsightsCalculator.longestStreak(in: entries) == 3)
    }

    @Test func longestStreak_gapInMiddle_returnsLongestSegment() {
        let entries = [
            entry(year: 2026, month: 1, day: 1),
            entry(year: 2026, month: 1, day: 2),
            entry(year: 2026, month: 1, day: 3),
            entry(year: 2026, month: 1, day: 5),
            entry(year: 2026, month: 1, day: 6)
        ]
        #expect(InsightsCalculator.longestStreak(in: entries) == 3)
    }

    @Test func longestStreak_multipleEntriesSameDay_doesNotBreakStreak() {
        let entries = [
            entry(year: 2026, month: 1, day: 1, hour: 9),
            entry(year: 2026, month: 1, day: 1, hour: 20),
            entry(year: 2026, month: 1, day: 2, hour: 12),
            entry(year: 2026, month: 1, day: 3, hour: 15)
        ]
        #expect(InsightsCalculator.longestStreak(in: entries) == 3)
    }

    @Test func longestStreak_acrossMonthBoundary_countsAsConsecutive() {
        let entries = [
            entry(year: 2026, month: 1, day: 31),
            entry(year: 2026, month: 2, day: 1)
        ]
        #expect(InsightsCalculator.longestStreak(in: entries) == 2)
    }

    @Test func longestStreak_allEntriesOnSameDay_returnsOne() {
        let entries = [
            entry(year: 2026, month: 1, day: 5, hour: 9),
            entry(year: 2026, month: 1, day: 5, hour: 13),
            entry(year: 2026, month: 1, day: 5, hour: 21)
        ]
        #expect(InsightsCalculator.longestStreak(in: entries) == 1)
    }

    // MARK: - calculateGoldenHours

    @Test func calculateGoldenHours_emptyList_returnsPlaceholder() {
        #expect(InsightsCalculator.calculateGoldenHours(entries: [], locale: .current) == "-- : --")
    }

    @Test func calculateGoldenHours_withEntries_returnsFormattedRange() {
        let entries = [
            entry(year: 2026, month: 1, day: 1, hour: 14),
            entry(year: 2026, month: 1, day: 2, hour: 14)
        ]
        let result = InsightsCalculator.calculateGoldenHours(entries: entries, locale: .current)
        #expect(result != "-- : --")
        #expect(result.contains(" - "))
    }

    @Test func calculateGoldenHours_singleEntry_returnsFormattedRange() {
        let entries = [entry(year: 2026, month: 1, day: 1, hour: 10)]
        let result = InsightsCalculator.calculateGoldenHours(entries: entries, locale: Locale(identifier: "en_GB"))
        #expect(result == "10:00 - 13:00")
    }

    @Test func calculateGoldenHours_mostFrequentHourWins() {
        let entries = [
            entry(year: 2026, month: 1, day: 1, hour: 10),
            entry(year: 2026, month: 1, day: 1, hour: 14),
            entry(year: 2026, month: 1, day: 2, hour: 14),
            entry(year: 2026, month: 1, day: 3, hour: 14)
        ]
        let result = InsightsCalculator.calculateGoldenHours(entries: entries, locale: Locale(identifier: "en_GB"))
        #expect(result == "14:00 - 17:00")
    }

    @Test func calculateGoldenHours_tieBreaking_picksHourWithLatestEntry() {
        let entries = [
            entry(year: 2026, month: 1, day: 1, hour: 10),
            entry(year: 2026, month: 1, day: 2, hour: 10),
            entry(year: 2026, month: 1, day: 3, hour: 14),
            entry(year: 2026, month: 2, day: 4, hour: 14)
        ]
        let result = InsightsCalculator.calculateGoldenHours(entries: entries, locale: Locale(identifier: "en_GB"))
        #expect(result == "14:00 - 17:00")
    }

    @Test func calculateGoldenHours_picksThreeHourWindowWithMostEntries() {
        // 9, 10 and 11 each have one entry, while 15 alone has two: the 9-12 window (3 entries) beats it.
        let entries = [
            entry(year: 2026, month: 1, day: 1, hour: 9),
            entry(year: 2026, month: 1, day: 2, hour: 10),
            entry(year: 2026, month: 1, day: 3, hour: 11),
            entry(year: 2026, month: 1, day: 4, hour: 15),
            entry(year: 2026, month: 1, day: 5, hour: 15)
        ]
        let result = InsightsCalculator.calculateGoldenHours(entries: entries, locale: Locale(identifier: "en_GB"))
        #expect(result == "09:00 - 12:00")
    }

    @Test func calculateGoldenHours_midnightWrapAround_producesValidRange() {
        let entries = [
            entry(year: 2026, month: 1, day: 1, hour: 23),
            entry(year: 2026, month: 1, day: 2, hour: 23),
            entry(year: 2026, month: 1, day: 3, hour: 23)
        ]
        let result = InsightsCalculator.calculateGoldenHours(entries: entries, locale: Locale(identifier: "en_GB"))
        #expect(result == "23:00 - 02:00")
    }
}
