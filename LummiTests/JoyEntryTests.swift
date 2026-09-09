import Testing
import Foundation
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
