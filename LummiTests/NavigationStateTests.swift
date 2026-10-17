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
        NavigationState(now: now)
    }

    // MARK: - Initial state

    @Test func init_startsOnHomeWithTodaySelected() {
        let state = makeState()
        #expect(state.screen == .home)
        #expect(state.selectedDate == now)
        #expect(state.paths.isEmpty)
    }

    // MARK: - navigate(to:)

    @Test func navigate_toInsights_activatesOnlyInsights() {
        var state = makeState()
        state.navigate(to: .insights, now: now)
        #expect(state.screen == .insights)
        #expect(state.isInsightsActive)
        #expect(!state.isSettingsActive)
        #expect(!state.showsHeader)
    }

    @Test func navigate_toSettings_closesInsightsPagesAndActivatesOnlySettings() {
        var state = makeState()
        state.navigate(to: .insights, now: now)
        state.push(.allJoys)
        state.push(.joysYear(2025))
        state.navigate(to: .settings, now: now)
        #expect(state.screen == .settings)
        #expect(state.paths[.insights]?.isEmpty ?? true)
        #expect(state.isSettingsActive)
        #expect(!state.isInsightsActive)
    }

    @Test func navigate_toSameTab_returnsItToItsRootPage() {
        var state = makeState()
        state.navigate(to: .settings, now: now)
        state.push(.language)
        state.navigate(to: .settings, now: now)
        #expect(state.screen == .settings)
        #expect(state.paths[.settings]?.isEmpty ?? true)
    }

    @Test func navigate_toHome_resetsSelectionToToday() {
        var state = makeState()
        state.selectedDate = makeDate(month: 8, day: 3)
        state.navigate(to: .settings, now: now)
        state.navigate(to: .home, now: now)
        #expect(state.screen == .home)
        #expect(state.selectedDate == now)
        #expect(state.showsHeader)
    }

    @Test func navigate_toInsightsOrSettings_keepsSelectedDate() {
        var state = makeState()
        let past = makeDate(month: 8, day: 3)
        state.selectedDate = past
        state.navigate(to: .insights, now: now)
        state.navigate(to: .settings, now: now)
        #expect(state.selectedDate == past)
    }

    @Test func navigate_sameScreenTwice_isIdempotent() {
        var state = makeState()
        state.navigate(to: .insights, now: now)
        let once = state
        state.navigate(to: .insights, now: now)
        #expect(state == once)
    }

    // MARK: - Record

    @Test func navigate_toRecord_pushesRecordOntoCurrentTabAndStaysOnIt() {
        var state = makeState()
        state.navigate(to: .insights, now: now)
        state.navigate(to: .record, now: now)
        #expect(state.screen == .insights)
        #expect(state.paths[.insights] == [.record])
        #expect(!state.isInsightsActive)
    }

    @Test func navigate_toRecord_fromHome_hidesHeaderAndKeepsOtherTabsUntouched() {
        var state = makeState()
        state.navigate(to: .record, now: now)
        #expect(state.screen == .home)
        #expect(state.paths[.home] == [.record])
        #expect(!state.showsHeader)
        #expect(!state.isHomeActive(now: now))
        #expect(state.paths[.insights] == nil)
    }

    @Test func navigate_toRecord_keepsSelectedDate() {
        var state = makeState()
        let past = makeDate(month: 8, day: 3)
        state.selectedDate = past
        state.navigate(to: .record, now: now)
        #expect(state.selectedDate == past)
    }

    @Test func navigate_toRecordTwice_pushesItOnlyOnce() {
        var state = makeState()
        state.navigate(to: .settings, now: now)
        state.navigate(to: .record, now: now)
        state.navigate(to: .record, now: now)
        #expect(state.paths[.settings] == [.record])
    }

    @Test func navigate_toRecordOverLanguagePage_stacksOnTopOfIt() {
        var state = makeState()
        state.navigate(to: .settings, now: now)
        state.push(.language)
        state.navigate(to: .record, now: now)
        #expect(state.paths[.settings] == [.language, .record])
    }

    @Test func navigate_toTabAfterRecord_returnsEveryTabToItsRoot() {
        var state = makeState()
        state.navigate(to: .record, now: now)
        state.navigate(to: .insights, now: now)
        state.navigate(to: .home, now: now)
        #expect(state.showsHeader)
        #expect(state.paths[.home]?.isEmpty ?? true)
    }

    // MARK: - push

    @Test func push_addsPagesToTheCurrentTabInOrder() {
        var state = makeState()
        state.navigate(to: .insights, now: now)
        state.push(.trends)
        state.push(.trendsYear(2025))
        #expect(state.paths[.insights] == [.trends, .trendsYear(2025)])
        #expect(state.paths[.home] == nil)
    }

    @Test func push_samePageTwice_keepsBothUnlessItIsRecord() {
        var state = makeState()
        state.navigate(to: .insights, now: now)
        state.push(.joysYear(2025))
        state.push(.joysYear(2025))
        #expect(state.paths[.insights] == [.joysYear(2025), .joysYear(2025)])
    }

    // MARK: - Route

    @Test func route_hidesTabBarOnEveryPageButLanguage() {
        #expect(Route.allJoys.hidesTabBar)
        #expect(Route.trends.hidesTabBar)
        #expect(Route.joysYear(2025).hidesTabBar)
        #expect(Route.trendsYear(2025).hidesTabBar)
        #expect(Route.record.hidesTabBar)
        #expect(!Route.language.hidesTabBar)
    }

    // MARK: - Derived state

    @Test func isHomeActive_trueOnlyOnHomeAndToday() {
        var state = makeState()
        #expect(state.isHomeActive(now: now))

        state.selectedDate = makeDate(month: 8, day: 3)
        #expect(!state.isHomeActive(now: now))

        state.selectedDate = now
        state.navigate(to: .insights, now: now)
        #expect(!state.isHomeActive(now: now))
    }

    @Test func isInsightsActive_falseWhileShowingAllJoys() {
        var state = makeState()
        state.navigate(to: .insights, now: now)
        state.push(.allJoys)
        #expect(!state.isInsightsActive)
    }

    @Test func isInsightsActive_falseWhileShowingTrends() {
        var state = makeState()
        state.navigate(to: .insights, now: now)
        state.push(.trends)
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
