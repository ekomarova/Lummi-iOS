import Testing
import Foundation
@testable import Lummi

struct NavigationStateTests {

    private let calendar = Calendar(identifier: .gregorian)

    private func makeDate(year: Int = 2026, month: Int, day: Int, hour: Int = 0, minute: Int = 0) -> Date {
        let components = DateComponents(year: year, month: month, day: day, hour: hour, minute: minute)
        return calendar.date(from: components) ?? Date()
    }

    private var now: Date { makeDate(month: 9, day: 24, hour: 15, minute: 30) }

    private func makeState() -> NavigationState {
        NavigationState(now: now, calendar: calendar)
    }

    // MARK: - Initial state

    @Test func init_startsOnHomeWithTodaySelectedAndCalendarCollapsed() {
        let state = makeState()
        #expect(state.screen == .home)
        #expect(state.selectedDate == now)
        #expect(state.visibleMonth == makeDate(month: 9, day: 1))
        #expect(!state.isCalendarExpanded)
        #expect(!state.isShowingAllJoys)
    }

    // MARK: - navigate(to:)

    @Test func navigate_toInsights_collapsesCalendarAndActivatesOnlyInsights() {
        var state = makeState()
        state.isCalendarExpanded = true
        state.navigate(to: .insights, now: now, calendar: calendar)
        #expect(state.screen == .insights)
        #expect(!state.isCalendarExpanded)
        #expect(state.isInsightsActive)
        #expect(!state.isSettingsActive)
        #expect(!state.showsHeader)
    }

    @Test func navigate_toSettings_closesAllJoysAndActivatesOnlySettings() {
        var state = makeState()
        state.navigate(to: .insights, now: now, calendar: calendar)
        state.isShowingAllJoys = true
        state.navigate(to: .settings, now: now, calendar: calendar)
        #expect(state.screen == .settings)
        #expect(!state.isShowingAllJoys)
        #expect(state.isSettingsActive)
        #expect(!state.isInsightsActive)
    }

    @Test func navigate_toHome_resetsSelectionToToday() {
        var state = makeState()
        state.selectedDate = makeDate(month: 8, day: 3)
        state.visibleMonth = makeDate(month: 8, day: 1)
        state.isCalendarExpanded = true
        state.navigate(to: .settings, now: now, calendar: calendar)
        state.navigate(to: .home, now: now, calendar: calendar)
        #expect(state.screen == .home)
        #expect(state.selectedDate == now)
        #expect(state.visibleMonth == makeDate(month: 9, day: 1))
        #expect(!state.isCalendarExpanded)
        #expect(state.showsHeader)
    }

    @Test func navigate_toInsightsOrSettings_keepsSelectedDate() {
        var state = makeState()
        let past = makeDate(month: 8, day: 3)
        state.selectedDate = past
        state.navigate(to: .insights, now: now, calendar: calendar)
        state.navigate(to: .settings, now: now, calendar: calendar)
        #expect(state.selectedDate == past)
    }

    @Test func navigate_toRecord_hidesToolbarAndHeader() {
        var state = makeState()
        state.navigate(to: .record, now: now, calendar: calendar)
        #expect(state.screen == .record)
        #expect(!state.showsToolbar)
        #expect(!state.showsHeader)
    }

    @Test func navigate_sameScreenTwice_isIdempotent() {
        var state = makeState()
        state.navigate(to: .insights, now: now, calendar: calendar)
        let once = state
        state.navigate(to: .insights, now: now, calendar: calendar)
        #expect(state == once)
    }

    @Test func navigate_toRecord_collapsesCalendarButKeepsSelectedDate() {
        var state = makeState()
        let past = makeDate(month: 8, day: 3)
        state.selectedDate = past
        state.isCalendarExpanded = true
        state.navigate(to: .record, now: now, calendar: calendar)
        #expect(!state.isCalendarExpanded)
        #expect(state.selectedDate == past)
    }

    // MARK: - closeRecord

    @Test func closeRecord_returnsToScreenItWasOpenedFrom() {
        var state = makeState()
        state.navigate(to: .insights, now: now, calendar: calendar)
        state.navigate(to: .record, now: now, calendar: calendar)
        state.closeRecord()
        #expect(state.screen == .insights)
    }

    @Test func closeRecord_fromHome_keepsSelectedDate() {
        var state = makeState()
        let past = makeDate(month: 8, day: 3)
        state.selectedDate = past
        state.navigate(to: .record, now: now, calendar: calendar)
        state.closeRecord()
        #expect(state.screen == .home)
        #expect(state.selectedDate == past)
    }

    @Test func closeRecord_openingRecordTwice_stillReturnsToOriginalScreen() {
        var state = makeState()
        state.navigate(to: .settings, now: now, calendar: calendar)
        state.navigate(to: .record, now: now, calendar: calendar)
        state.navigate(to: .record, now: now, calendar: calendar)
        state.closeRecord()
        #expect(state.screen == .settings)
    }

    @Test func closeRecord_whenNotOnRecord_doesNothing() {
        var state = makeState()
        state.navigate(to: .settings, now: now, calendar: calendar)
        state.closeRecord()
        #expect(state.screen == .settings)
    }

    // MARK: - Calendar

    @Test func dismissCalendar_collapsesAndResetsToToday() {
        var state = makeState()
        state.isCalendarExpanded = true
        state.selectedDate = makeDate(month: 7, day: 10)
        state.visibleMonth = makeDate(month: 7, day: 1)
        state.dismissCalendar(now: now, calendar: calendar)
        #expect(!state.isCalendarExpanded)
        #expect(state.selectedDate == now)
        #expect(state.visibleMonth == makeDate(month: 9, day: 1))
    }

    @Test func toggleCalendar_collapsing_snapsVisibleMonthToSelectedDate() {
        var state = makeState()
        state.toggleCalendar(calendar: calendar)
        #expect(state.isCalendarExpanded)
        state.selectedDate = makeDate(month: 8, day: 3)
        state.visibleMonth = makeDate(month: 5, day: 1)
        state.toggleCalendar(calendar: calendar)
        #expect(!state.isCalendarExpanded)
        #expect(state.visibleMonth == makeDate(month: 8, day: 1))
    }

    // MARK: - Derived state

    @Test func isHomeActive_trueOnlyOnHomeCollapsedAndToday() {
        var state = makeState()
        #expect(state.isHomeActive(now: now, calendar: calendar))

        state.selectedDate = makeDate(month: 8, day: 3)
        #expect(!state.isHomeActive(now: now, calendar: calendar))

        state.selectedDate = now
        state.isCalendarExpanded = true
        #expect(!state.isHomeActive(now: now, calendar: calendar))

        state.navigate(to: .insights, now: now, calendar: calendar)
        #expect(!state.isHomeActive(now: now, calendar: calendar))
    }

    @Test func isInsightsActive_falseWhileShowingAllJoys() {
        var state = makeState()
        state.navigate(to: .insights, now: now, calendar: calendar)
        state.isShowingAllJoys = true
        #expect(!state.isInsightsActive)
    }

    // MARK: - recordDate

    @Test func recordDate_isAlwaysNow_regardlessOfSelectedDay() {
        var state = makeState()
        #expect(state.recordDate(now: now) == now)

        state.selectedDate = makeDate(month: 8, day: 3)
        #expect(state.recordDate(now: now) == now)

        state.selectedDate = makeDate(month: 10, day: 2)
        #expect(state.recordDate(now: now) == now)
    }
}
