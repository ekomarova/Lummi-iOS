//
//  Required Notice: Copyright Evseniia Komarova (https://github.com/ekomarova)
//
//  Licensed under the PolyForm Noncommercial License 1.0.0.
//  See the LICENSE file in the repository root for full terms.
//  <https://polyformproject.org/licenses/noncommercial/1.0.0>
//

import Foundation

// Mutually exclusive top-level screens shown by `ContentView`.
enum Screen: nonisolated Equatable {
    case home
    case insights
    case settings
    case record
}

// Single source of truth for `ContentView` navigation, so impossible flag combinations cannot be represented.
struct NavigationState: nonisolated Equatable {
    private(set) var screen: Screen = .home
    private var screenBeforeRecord: Screen = .home
    var isCalendarExpanded = false
    var isShowingAllJoys = false
    var isShowingTrends = false
    var selectedDate: Date
    var visibleMonth: Date

    init(now: Date = Date(), calendar: Calendar = .current) {
        selectedDate = now
        visibleMonth = calendar.monthStart(for: now) ?? now
    }

    // MARK: - Transitions

    // The one code path for switching screens. Switching always collapses the calendar; going home also
    // resets the selection to today, and switching between the tabs closes Insights' nested "all joys" and
    // "trends" pages. Opening the record screen remembers where it came from so `closeRecord()` can return there.
    mutating func navigate(to target: Screen, now: Date = Date(), calendar: Calendar = .current) {
        if target == .record {
            if screen != .record { screenBeforeRecord = screen }
        } else {
            isShowingAllJoys = false
            isShowingTrends = false
        }
        screen = target
        isCalendarExpanded = false
        if target == .home {
            resetToToday(now: now, calendar: calendar)
        }
    }

    // Leaves the record screen for the one it was opened from, keeping the current selection.
    mutating func closeRecord() {
        guard screen == .record else { return }
        screen = screenBeforeRecord
    }

    // Collapses the calendar and returns the selection to today.
    mutating func dismissCalendar(now: Date = Date(), calendar: Calendar = .current) {
        isCalendarExpanded = false
        resetToToday(now: now, calendar: calendar)
    }

    mutating func toggleCalendar(calendar: Calendar = .current) {
        isCalendarExpanded.toggle()
        if !isCalendarExpanded {
            visibleMonth = calendar.monthStart(for: selectedDate) ?? selectedDate
        }
    }

    // MARK: - Derived UI state

    var showsHeader: Bool { screen == .home }

    // Tab highlighted in the tab bar. The record screen is a one-shot action, so while it is open the tab it was
    // opened from stays selected and the tab bar returns to it afterwards.
    var selectedTab: Screen { screen == .record ? screenBeforeRecord : screen }

    // Hidden on the record screen and on Insights' nested "all joys" / "trends" pages, which use the
    // full-bleed space the toolbar would otherwise float over.
    var showsToolbar: Bool { screen != .record && !isShowingAllJoys && !isShowingTrends }

    func isHomeActive(now: Date = Date(), calendar: Calendar = .current) -> Bool {
        screen == .home && !isCalendarExpanded && calendar.isDate(selectedDate, inSameDayAs: now)
    }

    var isInsightsActive: Bool { screen == .insights && !isShowingAllJoys && !isShowingTrends }

    var isSettingsActive: Bool { screen == .settings }

    // MARK: - Record date

    // Date stored on a new record. Records are always created for today, whichever day is selected in the calendar.
    func recordDate(now: Date = Date()) -> Date { now }

    // MARK: - Private

    private mutating func resetToToday(now: Date, calendar: Calendar) {
        selectedDate = now
        visibleMonth = calendar.monthStart(for: now) ?? now
    }
}
