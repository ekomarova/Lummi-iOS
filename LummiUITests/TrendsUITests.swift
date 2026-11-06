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
        let insightsTabButton = app.tabItem("Insights", identifier: "InsightsButton")
        XCTAssertTrue(insightsTabButton.waitForExistence(timeout: 2.0))
        insightsTabButton.tap()

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
        app.tabItem("Insights", identifier: "InsightsButton").tap()

        let showTrends = app.buttons["ShowTrendsButton"]
        XCTAssertTrue(showTrends.waitForExistence(timeout: 2.0), "View Trends button did not appear on the Insights screen")
    }

    // 2. Tapping into Trends lists the years, with no Month/All Time tabs.
    func test_TrendsOpensWithYearsOnly() throws {
        launchApp(with: ["-UI_TESTING_INSIGHTS_TWO_MONTHS"])
        openTrends()

        let currentYear = Calendar.current.component(.year, from: Date())
        XCTAssertTrue(app.buttons["TrendsYearRow_\(currentYear)"].waitForExistence(timeout: 2.0), "Current year row was not found")
        XCTAssertFalse(app.buttons["Month"].exists, "The Month tab should be gone")
        XCTAssertFalse(app.buttons["All Time"].exists, "The tab picker should be gone")
    }

    // 3. Empty state copy appears when the journal has no entries at all.
    func test_TrendsEmptyState() throws {
        launchApp(with: ["-UI_TESTING"])
        openTrends()

        XCTAssertTrue(app.staticTexts["Add at least one joy"].waitForExistence(timeout: 2.0), "Trends did not show the empty state")
    }

    // MARK: - Other tests

    // 5 & 6. With several entries, Trends lists the current year, and that year's page shows
    // every card and chart.
    func test_TrendsAllTimeCurrentYearShowsAllSections() throws {
        launchApp(with: ["-UI_TESTING_INSIGHTS_TWO_MONTHS"])
        openTrends()

        let currentYear = Calendar.current.component(.year, from: Date())
        let yearRow = app.buttons["TrendsYearRow_\(currentYear)"]
        XCTAssertTrue(yearRow.waitForExistence(timeout: 2.0), "Current year row was not found in Trends")

        yearRow.tap()
        assertYearPageShowsAllSections()
    }

    // 7. With entries in both the current year and the previous one, Trends lists both years,
    // and each year's page shows every card and chart.
    func test_TrendsAllTimeMultipleYearsShowsAllSections() throws {
        launchApp(with: ["-UI_TESTING_TRENDS_MULTI_YEAR"])
        openTrends()

        let currentYear = Calendar.current.component(.year, from: Date())
        let previousYear = currentYear - 1

        let currentYearRow = app.buttons["TrendsYearRow_\(currentYear)"]
        let previousYearRow = app.buttons["TrendsYearRow_\(previousYear)"]
        XCTAssertTrue(currentYearRow.waitForExistence(timeout: 2.0), "Current year row was not found in Trends")
        XCTAssertTrue(previousYearRow.waitForExistence(timeout: 2.0), "Previous year row was not found in Trends")

        currentYearRow.tap()
        assertYearPageShowsAllSections()

        app.navigationBackButton.tap()
        // Waits out the return transition before the next tap, same as `openTrends()` does.
        XCTAssertTrue(previousYearRow.waitForExistence(timeout: 2.0), "Previous year row did not reappear in Trends")

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
