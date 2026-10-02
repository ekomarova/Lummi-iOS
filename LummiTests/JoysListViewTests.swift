import Testing
import Foundation
@testable import Lummi

struct JoysListViewTests {

    private let calendar = Calendar(identifier: .gregorian)

    private func makeDate(month: Int, day: Int, hour: Int = 12, minute: Int = 0) -> Date {
        var components = DateComponents()
        components.year = 2026
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute
        return calendar.date(from: components) ?? Date()
    }

    @Test func showsDate_firstEntry_alwaysShowsDate() {
        #expect(JoysListView.showsDate(for: makeDate(month: 9, day: 24), after: nil, calendar: calendar))
    }

    @Test func showsDate_sameDayAsEntryAbove_hidesDate() {
        let above = makeDate(month: 9, day: 24, hour: 18)
        let entry = makeDate(month: 9, day: 24, hour: 9)
        #expect(!JoysListView.showsDate(for: entry, after: above, calendar: calendar))
    }

    @Test func showsDate_differentDayFromEntryAbove_showsDate() {
        let above = makeDate(month: 9, day: 24)
        let entry = makeDate(month: 9, day: 23)
        #expect(JoysListView.showsDate(for: entry, after: above, calendar: calendar))
    }

    @Test func showsDate_acrossMidnight_treatsEntriesAsDifferentDays() {
        let above = makeDate(month: 9, day: 24, hour: 0, minute: 5)
        let entry = makeDate(month: 9, day: 23, hour: 23, minute: 55)
        #expect(JoysListView.showsDate(for: entry, after: above, calendar: calendar))
    }

    @Test func showsDate_sameDayOfDifferentMonth_showsDate() {
        let above = makeDate(month: 10, day: 5)
        let entry = makeDate(month: 9, day: 5)
        #expect(JoysListView.showsDate(for: entry, after: above, calendar: calendar))
    }
}
