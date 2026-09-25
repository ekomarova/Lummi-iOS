import Testing
import Foundation
import SwiftData
@testable import Lummi

struct JoyEntryTests {

    private func makeDate(year: Int, month: Int, day: Int) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        return Calendar.current.date(from: components) ?? Date()
    }

    // MARK: - dateKey

    @Test func dateKey_matchesDateStringKey() {
        let date = makeDate(year: 2026, month: 3, day: 5)
        let entry = JoyEntry(text: "test", date: date)
        #expect(entry.dateKey == "2026-03-05")
        #expect(entry.dateKey == date.stringKey)
    }

    @Test func dateKey_twoEntriesOnSameDay_haveEqualKeys() {
        let morning = makeDate(year: 2026, month: 6, day: 10)
        let evening = Calendar.current.date(byAdding: .hour, value: 14, to: morning) ?? morning
        let entryA = JoyEntry(text: "morning", date: morning)
        let entryB = JoyEntry(text: "evening", date: evening)
        #expect(entryA.dateKey == entryB.dateKey)
    }

    @Test func dateKey_twoEntriesOnDifferentDays_haveDifferentKeys() {
        let entryA = JoyEntry(text: "a", date: makeDate(year: 2026, month: 1, day: 10))
        let entryB = JoyEntry(text: "b", date: makeDate(year: 2026, month: 6, day: 20))
        #expect(entryA.dateKey != entryB.dateKey)
        #expect(entryA.dateKey == "2026-01-10")
        #expect(entryB.dateKey == "2026-06-20")
    }
}

@MainActor
struct JoyEntryQueriesTests {

    private let calendar = Calendar.current

    private func makeContext() throws -> ModelContext {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true, cloudKitDatabase: .none)
        let container = try ModelContainer(for: JoyEntry.self, configurations: configuration)
        return ModelContext(container)
    }

    private func makeDate(year: Int, month: Int, day: Int, hour: Int = 0, minute: Int = 0, second: Int = 0) -> Date {
        let components = DateComponents(year: year, month: month, day: day, hour: hour, minute: minute, second: second)
        return calendar.date(from: components) ?? Date()
    }

    private func texts(_ predicate: Predicate<JoyEntry>, in context: ModelContext) throws -> [String] {
        let descriptor = FetchDescriptor<JoyEntry>(predicate: predicate, sortBy: [SortDescriptor(\.date)])
        return try context.fetch(descriptor).map(\.text)
    }

    // MARK: - Calendar ranges

    @Test func dayRange_coversFromStartOfDayToStartOfNextDay() throws {
        let range = try #require(calendar.dayRange(for: makeDate(year: 2026, month: 3, day: 5, hour: 15)))
        #expect(range.lowerBound == makeDate(year: 2026, month: 3, day: 5))
        #expect(range.upperBound == makeDate(year: 2026, month: 3, day: 6))
    }

    @Test func dayRange_lastDayOfMonth_endsOnFirstOfNextMonth() throws {
        let range = try #require(calendar.dayRange(for: makeDate(year: 2026, month: 1, day: 31, hour: 23)))
        #expect(range.upperBound == makeDate(year: 2026, month: 2, day: 1))
    }

    @Test func monthRange_coversWholeMonth() throws {
        let range = try #require(calendar.monthRange(for: makeDate(year: 2026, month: 2, day: 14)))
        #expect(range.lowerBound == makeDate(year: 2026, month: 2, day: 1))
        #expect(range.upperBound == makeDate(year: 2026, month: 3, day: 1))
    }

    @Test func monthRange_leapFebruary_includesFebruary29() throws {
        let range = try #require(calendar.monthRange(for: makeDate(year: 2028, month: 2, day: 1)))
        #expect(range.contains(makeDate(year: 2028, month: 2, day: 29, hour: 23, minute: 59)))
        #expect(!range.contains(makeDate(year: 2028, month: 3, day: 1)))
    }

    // MARK: - Day predicate

    @Test func dayPredicate_matchesOnlyThatDay_includingBoundaries() throws {
        let context = try makeContext()
        context.insert(JoyEntry(text: "before", date: makeDate(year: 2026, month: 3, day: 4, hour: 23, minute: 59, second: 59)))
        context.insert(JoyEntry(text: "midnight", date: makeDate(year: 2026, month: 3, day: 5)))
        context.insert(JoyEntry(text: "noon", date: makeDate(year: 2026, month: 3, day: 5, hour: 12)))
        context.insert(JoyEntry(text: "last second", date: makeDate(year: 2026, month: 3, day: 5, hour: 23, minute: 59, second: 59)))
        context.insert(JoyEntry(text: "next midnight", date: makeDate(year: 2026, month: 3, day: 6)))

        let result = try texts(JoyEntry.dayPredicate(for: makeDate(year: 2026, month: 3, day: 5, hour: 8)), in: context)
        #expect(result == ["midnight", "noon", "last second"])
    }

    @Test func dayPredicate_dayWithoutEntries_isEmpty() throws {
        let context = try makeContext()
        context.insert(JoyEntry(text: "other day", date: makeDate(year: 2026, month: 3, day: 5, hour: 12)))
        #expect(try texts(JoyEntry.dayPredicate(for: makeDate(year: 2026, month: 3, day: 7)), in: context).isEmpty)
    }

    @Test func dayPredicate_agreesWithDateKey() throws {
        let context = try makeContext()
        let target = makeDate(year: 2026, month: 3, day: 5, hour: 9)
        for hour in [0, 1, 11, 12, 22, 23] {
            for day in 4...6 {
                context.insert(JoyEntry(text: "\(day)-\(hour)", date: makeDate(year: 2026, month: 3, day: day, hour: hour)))
            }
        }
        let all = try context.fetch(FetchDescriptor<JoyEntry>(sortBy: [SortDescriptor(\.date)]))
        let expected = all.filter { $0.dateKey == target.stringKey }.map(\.text)
        #expect(try texts(JoyEntry.dayPredicate(for: target), in: context) == expected)
        #expect(!expected.isEmpty)
    }

    // MARK: - Month predicate

    @Test func monthPredicate_matchesOnlyThatMonth_includingBoundaries() throws {
        let context = try makeContext()
        context.insert(JoyEntry(text: "jan end", date: makeDate(year: 2026, month: 1, day: 31, hour: 23, minute: 59, second: 59)))
        context.insert(JoyEntry(text: "feb start", date: makeDate(year: 2026, month: 2, day: 1)))
        context.insert(JoyEntry(text: "feb mid", date: makeDate(year: 2026, month: 2, day: 14, hour: 10)))
        context.insert(JoyEntry(text: "feb end", date: makeDate(year: 2026, month: 2, day: 28, hour: 23, minute: 59, second: 59)))
        context.insert(JoyEntry(text: "mar start", date: makeDate(year: 2026, month: 3, day: 1)))
        context.insert(JoyEntry(text: "feb last year", date: makeDate(year: 2025, month: 2, day: 14)))

        let result = try texts(JoyEntry.monthPredicate(for: makeDate(year: 2026, month: 2, day: 10)), in: context)
        #expect(result == ["feb start", "feb mid", "feb end"])
    }

    @Test func monthPredicate_agreesWithInsightsCalculatorFilter() throws {
        let context = try makeContext()
        let month = makeDate(year: 2026, month: 5, day: 1)
        for day in stride(from: 1, through: 28, by: 3) {
            for monthNumber in 4...6 {
                context.insert(JoyEntry(text: "\(monthNumber)-\(day)", date: makeDate(year: 2026, month: monthNumber, day: day, hour: 7)))
            }
        }
        let all = try context.fetch(FetchDescriptor<JoyEntry>(sortBy: [SortDescriptor(\.date)]))
        let expected = InsightsCalculator.filterEntries(all, for: month).map(\.text)
        #expect(try texts(JoyEntry.monthPredicate(for: month), in: context) == expected)
    }

    @Test func predicate_nilRange_matchesNothing() throws {
        let context = try makeContext()
        context.insert(JoyEntry(text: "any", date: Date()))
        #expect(try texts(JoyEntry.predicate(in: nil), in: context).isEmpty)
    }

    // MARK: - Oldest entry

    @Test func oldestEntryDescriptor_returnsOnlyTheOldest() throws {
        let context = try makeContext()
        context.insert(JoyEntry(text: "newer", date: makeDate(year: 2026, month: 3, day: 1)))
        context.insert(JoyEntry(text: "oldest", date: makeDate(year: 2024, month: 7, day: 9)))
        context.insert(JoyEntry(text: "middle", date: makeDate(year: 2025, month: 1, day: 1)))

        let result = try context.fetch(JoyEntry.oldestEntryDescriptor)
        #expect(result.map(\.text) == ["oldest"])
    }

    @Test func oldestEntryDescriptor_emptyStore_returnsNothing() throws {
        let context = try makeContext()
        #expect(try context.fetch(JoyEntry.oldestEntryDescriptor).isEmpty)
    }

    // MARK: - Large dataset

    @Test func predicates_largeDataset_returnExactlyTheRequestedRange() throws {
        let context = try makeContext()
        let firstDay = makeDate(year: 2020, month: 1, day: 1, hour: 8)
        let dayCount = 2_500
        // Two entries per day: 5,000 in total
        for offset in 0..<dayCount {
            let day = try #require(calendar.date(byAdding: .day, value: offset, to: firstDay))
            context.insert(JoyEntry(text: "morning", date: day))
            context.insert(JoyEntry(text: "evening", date: day.addingTimeInterval(10 * 3600)))
        }
        try context.save()
        #expect(try context.fetchCount(FetchDescriptor<JoyEntry>()) == dayCount * 2)

        let someDay = makeDate(year: 2023, month: 6, day: 15)
        #expect(try texts(JoyEntry.dayPredicate(for: someDay), in: context) == ["morning", "evening"])

        let june = makeDate(year: 2023, month: 6, day: 1)
        #expect(try texts(JoyEntry.monthPredicate(for: june), in: context).count == 30 * 2)

        let oldest = try context.fetch(JoyEntry.oldestEntryDescriptor)
        #expect(oldest.first?.date == firstDay)
    }
}
