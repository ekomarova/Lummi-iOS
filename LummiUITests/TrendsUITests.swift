import XCTest

final class TrendsUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    private func launchApp(with arguments: [String]) {
        app.launchArguments = arguments
        app.launch()
    }

    // Opens Insights, then taps "View Trends" to reach the Trends screen.
    private func openTrends() {
        let inactiveInsightsBtn = app.buttons["InsightsButton_Inactive"]
        XCTAssertTrue(inactiveInsightsBtn.waitForExistence(timeout: 2.0))
        inactiveInsightsBtn.tap()

        let showTrends = app.buttons["ShowTrendsButton"]
        XCTAssertTrue(showTrends.waitForExistence(timeout: 2.0), "View Trends button was not found on the Insights screen")
        showTrends.tap()

        // Waits out the screen's slide-in transition, so a tap right after this helper lands on the
        // settled Trends screen instead of mid-animation, where it can silently miss its target.
        XCTAssertTrue(app.staticTexts["Trends"].waitForExistence(timeout: 2.0), "Trends header did not appear")
    }

    // MARK: - Default tests

    // 1. The Trends entry point exists on the Insights screen.
    func test_TrendsEntryPointExists() throws {
        launchApp(with: [""])
        app.buttons["InsightsButton_Inactive"].tap()

        let showTrends = app.buttons["ShowTrendsButton"]
        XCTAssertTrue(showTrends.waitForExistence(timeout: 2.0), "View Trends button did not appear on the Insights screen")
    }

    // 2. Tapping into Trends shows its header plus the Month/All Time tabs.
    func test_TrendsOpensWithMonthAndAllTimeTabs() throws {
        launchApp(with: [""])
        openTrends()

        XCTAssertTrue(app.buttons["Month"].waitForExistence(timeout: 2.0), "Month tab was not found")
        XCTAssertTrue(app.buttons["All Time"].waitForExistence(timeout: 2.0), "All Time tab was not found")
    }

    // 3. Empty state copy appears in both tabs when the journal has no entries at all.
    func test_TrendsEmptyStateInBothTabs() throws {
        launchApp(with: ["-UI_TESTING"])
        openTrends()

        let emptyStateText = "Add at least one joy to see trends"
        XCTAssertTrue(app.staticTexts[emptyStateText].waitForExistence(timeout: 2.0), "Month tab did not show the empty state")

        app.buttons["All Time"].tap()
        XCTAssertTrue(app.staticTexts[emptyStateText].waitForExistence(timeout: 2.0), "All Time tab did not show the empty state")
    }

    // MARK: - Other tests

    // 4. With several entries this month, the Month tab shows its cards and charts.
    func test_TrendsMonthTabWithEntriesShowsAllSections() throws {
        launchApp(with: ["-UI_TESTING_INSIGHTS_TWO_MONTHS"])
        openTrends()

        XCTAssertTrue(app.buttons["Month"].waitForExistence(timeout: 2.0))
        XCTAssertTrue(app.staticTexts["Joys"].waitForExistence(timeout: 2.0))
        XCTAssertTrue(app.staticTexts["Active Days"].waitForExistence(timeout: 2.0))
        XCTAssertTrue(app.staticTexts["Day Streak"].waitForExistence(timeout: 2.0))
        XCTAssertTrue(app.staticTexts["Joys By Date"].waitForExistence(timeout: 2.0))
        XCTAssertTrue(app.staticTexts["Joys By Weekday"].waitForExistence(timeout: 2.0))
    }

    // 5 & 6. With several entries, All Time lists the current year, and that year's page shows
    // every card and chart.
    func test_TrendsAllTimeCurrentYearShowsAllSections() throws {
        launchApp(with: ["-UI_TESTING_INSIGHTS_TWO_MONTHS"])
        openTrends()
        app.buttons["All Time"].tap()

        let currentYear = Calendar.current.component(.year, from: Date())
        let yearRow = app.buttons["TrendsYearRow_\(currentYear)"]
        XCTAssertTrue(yearRow.waitForExistence(timeout: 2.0), "Current year row was not found in All Time")

        yearRow.tap()
        assertYearPageShowsAllSections()
    }

    // 7. With entries in both the current year and the previous one, All Time lists both years,
    // and each year's page shows every card and chart.
    func test_TrendsAllTimeMultipleYearsShowsAllSections() throws {
        launchApp(with: ["-UI_TESTING_TRENDS_MULTI_YEAR"])
        openTrends()
        app.buttons["All Time"].tap()

        let currentYear = Calendar.current.component(.year, from: Date())
        let previousYear = currentYear - 1

        let currentYearRow = app.buttons["TrendsYearRow_\(currentYear)"]
        let previousYearRow = app.buttons["TrendsYearRow_\(previousYear)"]
        XCTAssertTrue(currentYearRow.waitForExistence(timeout: 2.0), "Current year row was not found in All Time")
        XCTAssertTrue(previousYearRow.waitForExistence(timeout: 2.0), "Previous year row was not found in All Time")

        currentYearRow.tap()
        assertYearPageShowsAllSections()

        app.buttons["YearTrendsBackButton"].tap()
        // Waits out the return transition before the next tap, same as `openTrends()` does.
        XCTAssertTrue(previousYearRow.waitForExistence(timeout: 2.0), "Previous year row did not reappear in All Time")

        previousYearRow.tap()
        assertYearPageShowsAllSections()
    }

    // MARK: - Helpers

    // Checks every card and chart on a year's Trends page.
    private func assertYearPageShowsAllSections() {
        XCTAssertTrue(app.staticTexts["Joys"].waitForExistence(timeout: 2.0))
        XCTAssertTrue(app.staticTexts["Active Days"].waitForExistence(timeout: 2.0))
        XCTAssertTrue(app.staticTexts["Day Streak"].waitForExistence(timeout: 2.0))
        XCTAssertTrue(app.staticTexts["Joyful Hours"].waitForExistence(timeout: 2.0))
        XCTAssertTrue(app.staticTexts["Joys By Month"].waitForExistence(timeout: 2.0))
        XCTAssertTrue(app.staticTexts["Joys By Weekday"].waitForExistence(timeout: 2.0))
    }
}
