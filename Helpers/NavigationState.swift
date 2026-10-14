//
//  Required Notice: Copyright Evseniia Komarova (https://github.com/ekomarova)
//
//  Licensed under the PolyForm Noncommercial License 1.0.0.
//  See the LICENSE file in the repository root for full terms.
//  <https://polyformproject.org/licenses/noncommercial/1.0.0>
//

import Foundation

// Top-level tabs shown by `ContentView`. `.record` is the detached "New Joy" tab: an action that pushes the record
// page onto the current tab, so it is never the selected screen.
enum Screen: nonisolated Equatable, nonisolated Hashable {
    case home
    case insights
    case settings
    case record
}

// A page pushed onto a tab's `NavigationStack`, so the system back button and swipe-back gesture work on it.
enum Route: nonisolated Equatable, nonisolated Hashable {
    case allJoys
    case trends
    case joysYear(Int)
    case trendsYear(Int)
    case language
    case record

    // Pages that use the full-bleed space the tab bar would otherwise float over. The language list keeps it.
    var hidesTabBar: Bool { self != .language }
}

// Single source of truth for `ContentView` navigation: the selected tab and the pages pushed onto each tab.
struct NavigationState: nonisolated Equatable {
    private(set) var screen: Screen = .home
    // Pushed pages per tab, bound to that tab's `NavigationStack`. A tab with no entry shows its root page.
    var paths: [Screen: [Route]] = [:]
    var isCalendarExpanded = false
    var selectedDate: Date
    var visibleMonth: Date

    init(now: Date = Date(), calendar: Calendar = .current) {
        selectedDate = now
        visibleMonth = calendar.monthStart(for: now) ?? now
    }

    // MARK: - Transitions

    // The one code path for switching screens. Switching to a tab (or tapping the selected one again) always
    // collapses the calendar and returns every tab to its root page; going home also resets the selection to today.
    // The record tab only pushes the record page onto the current tab, keeping the selected day.
    mutating func navigate(to target: Screen, now: Date = Date(), calendar: Calendar = .current) {
        if target == .record {
            push(.record)
        } else {
            paths = [:]
            screen = target
        }
        isCalendarExpanded = false
        if target == .home {
            resetToToday(now: now, calendar: calendar)
        }
    }

    // Pushes a page onto the current tab. The record page is never pushed twice in a row.
    mutating func push(_ route: Route) {
        if route == .record && paths[screen]?.last == .record { return }
        paths[screen, default: []].append(route)
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

    // Whether the current tab shows its root page rather than a pushed one.
    private var isAtRoot: Bool { paths[screen]?.isEmpty ?? true }

    // The tab bar gives way to the page pushed on top of the current tab, when that page needs the full screen.
    var hidesTabBar: Bool { paths[screen]?.last?.hidesTabBar ?? false }

    var showsHeader: Bool { screen == .home && isAtRoot }

    func isHomeActive(now: Date = Date(), calendar: Calendar = .current) -> Bool {
        showsHeader && !isCalendarExpanded && calendar.isDate(selectedDate, inSameDayAs: now)
    }

    var isInsightsActive: Bool { screen == .insights && isAtRoot }

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
