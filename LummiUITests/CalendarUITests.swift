import XCTest

// The calendar of the current month in Insights' Highlights: read-only, a star over every day with entries.
final class CalendarUITests: XCTestCase {

    var app: XCUIApplication!

    let today = Date()

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Tests

    // The calendar shows today
    func test_InsightsShowsCurrentMonthCalendar() throws {
        launchAndOpenInsights(with: [""])

        let todayCell = dayCell(for: today)
        XCTAssertTrue(scrollToExist(todayCell), "Today's cell is missing")
        XCTAssertEqual(todayCell.value as? String, "Empty")
    }

    // Days with entries are marked, the others are not
    func test_DaysWithEntriesAreFilled() throws {
        launchAndOpenInsights(with: ["-UI_TESTING_4_DAYS_FILLED"])

        // The mock entries fill the 12th to the 15th of the current month. The calendar draws two weeks at a time,
        // but every day is in the hierarchy, so the cells are read without scrolling it.
        for day in 12...15 {
            let cell = dayCell(for: dayOfCurrentMonth(day))
            XCTAssertTrue(scrollToExist(cell), "Cell of day \(day) is missing")
            XCTAssertEqual(cell.value as? String, "Filled", "Day \(day) has an entry but no star")
        }
        let emptyCell = dayCell(for: dayOfCurrentMonth(11))
        XCTAssertTrue(scrollToExist(emptyCell))
        XCTAssertEqual(emptyCell.value as? String, "Empty")
    }

    // The calendar draws two weeks at a time: from the top of the month at most 14 days are on screen
    func test_CalendarShowsTwoWeeksAtATime() throws {
        launchAndOpenInsights(with: [""])
        let calendar = app.scrollViews["MonthCalendar"]
        XCTAssertTrue(calendar.waitForExistence(timeout: 5.0), "The calendar is missing")

        scroll(calendar, down: true, until: dayCell(for: dayOfCurrentMonth(1)))

        XCTAssertTrue(isVisible(dayCell(for: dayOfCurrentMonth(1)), in: calendar), "The first day of the month is not visible at the top")
        let visibleDays = visibleDayCount(in: calendar)
        XCTAssertTrue((1...14).contains(visibleDays), "Expected at most two weeks on screen, found \(visibleDays) days")
        XCTAssertFalse(
            isVisible(dayCell(for: dayOfCurrentMonth(lastDayOfMonth)), in: calendar),
            "The whole month is on screen at once"
        )
    }

    // Scrolling the calendar pages through the weeks to the end of the month, and back
    func test_ScrollingCalendarReachesEndOfMonthAndBack() throws {
        launchAndOpenInsights(with: [""])
        let calendar = app.scrollViews["MonthCalendar"]
        XCTAssertTrue(calendar.waitForExistence(timeout: 5.0), "The calendar is missing")

        let firstDay = dayCell(for: dayOfCurrentMonth(1))
        let lastDay = dayCell(for: dayOfCurrentMonth(lastDayOfMonth))

        scroll(calendar, down: false, until: lastDay)
        XCTAssertTrue(isVisible(lastDay, in: calendar), "Scrolling did not reach the last day of the month")
        XCTAssertFalse(isVisible(firstDay, in: calendar), "The first day is still on screen at the end of the month")
        XCTAssertLessThanOrEqual(visibleDayCount(in: calendar), 14, "More than two weeks are on screen")

        scroll(calendar, down: true, until: firstDay)
        XCTAssertTrue(isVisible(firstDay, in: calendar), "Scrolling back did not reach the first day of the month")
        XCTAssertFalse(isVisible(lastDay, in: calendar), "The last day is still on screen at the start of the month")
    }

    // The days are not buttons: the calendar only shows the month
    func test_DaysAreNotTappable() throws {
        launchAndOpenInsights(with: [""])

        XCTAssertTrue(scrollToExist(dayCell(for: today)))
        XCTAssertFalse(app.buttons["DayCell_\(today.uiTestDateKey)"].exists, "A day of the calendar is a button")
    }

    // Home has no calendar any more: its date is only a title
    func test_HomeHasNoCalendar() throws {
        app.launch()

        XCTAssertTrue(app.staticTexts["HeaderDateText"].waitForExistence(timeout: 5.0))
        XCTAssertFalse(app.buttons["HeaderToggleButton"].exists, "The date title on Home is still a button")
        XCTAssertFalse(dayCell(for: today).exists, "The calendar is shown on Home")
    }

    // MARK: - Helpers

    private func launchAndOpenInsights(with arguments: [String]) {
        app.launchArguments = arguments
        app.launch()
        let insightsTab = app.tabItem("Insights", identifier: "InsightsButton")
        XCTAssertTrue(insightsTab.waitForExistence(timeout: 5.0), "Insights tab was not found")
        insightsTab.tap()
    }

    private func dayCell(for date: Date) -> XCUIElement {
        app.descendants(matching: .any)["DayCell_\(date.uiTestDateKey)"]
    }

    private func dayOfCurrentMonth(_ day: Int) -> Date {
        var components = Calendar.current.dateComponents([.year, .month], from: today)
        components.day = day
        return Calendar.current.date(from: components) ?? today
    }

    private var lastDayOfMonth: Int {
        Calendar.current.range(of: .day, in: .month, for: today)?.count ?? 28
    }

    // Whether the center of `cell` is inside the calendar's window. `isHittable` is not enough: it stays true for the
    // days the window clips away.
    private func isVisible(_ cell: XCUIElement, in calendar: XCUIElement) -> Bool {
        guard cell.exists else { return false }
        let frame = cell.frame
        return calendar.frame.contains(CGPoint(x: frame.midX, y: frame.midY))
    }

    // Number of day cells inside the two-week window
    private func visibleDayCount(in calendar: XCUIElement) -> Int {
        app.descendants(matching: .any)
            .matching(NSPredicate(format: "identifier BEGINSWITH %@", "DayCell_"))
            .allElementsBoundByIndex
            .filter { isVisible($0, in: calendar) }
            .count
    }

    // Swipes the calendar (down shows earlier weeks, up later ones) until `target` is in its window; a month has at most six weeks
    private func scroll(_ calendar: XCUIElement, down: Bool, until target: XCUIElement) {
        var swipes = 0
        while !isVisible(target, in: calendar) && swipes < 6 {
            if down { calendar.swipeDown() } else { calendar.swipeUp() }
            swipes += 1
        }
    }

    // The calendar sits among the highlight cards, so it may need a scroll to be built
    private func scrollToExist(_ element: XCUIElement) -> Bool {
        var swipes = 0
        while !element.waitForExistence(timeout: 1.5) && swipes < 3 {
            app.swipeUp()
            swipes += 1
        }
        return element.exists
    }
}
