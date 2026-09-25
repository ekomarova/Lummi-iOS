import XCTest

// Performance measurements on a 5,000-entry store (`-UI_TESTING_5K_ENTRIES`, in-memory, never touches real data).
// Each iteration relaunches the app and measures only the interaction, so numbers are comparable between branches.
//
// Manual only: every test is skipped unless RUN_PERFORMANCE_TESTS=1 is set, so CI and normal UI test runs never pay
// for it (about 8 minutes). From the terminal:
//   TEST_RUNNER_RUN_PERFORMANCE_TESTS=1 xcodebuild test -scheme Lummi -destination 'platform=iOS Simulator,name=iPhone 17' \
//     -only-testing:LummiUITests/PerformanceUITests
// In Xcode, add RUN_PERFORMANCE_TESTS=1 under Edit Scheme > Test > Arguments > Environment Variables (do not commit it).
final class PerformanceUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        try XCTSkipUnless(
            ProcessInfo.processInfo.environment["RUN_PERFORMANCE_TESTS"] == "1",
            "Performance tests are manual: set RUN_PERFORMANCE_TESTS=1 to run them"
        )
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["-UI_TESTING_5K_ENTRIES"]
    }

    override func tearDownWithError() throws {
        app = nil
    }

    private var options: XCTMeasureOptions {
        let options = XCTMeasureOptions()
        options.iterationCount = 5
        return options
    }

    // For tests that set the app up first and measure only the interaction (startMeasuring / stopMeasuring)
    private var manualOptions: XCTMeasureOptions {
        let options = options
        options.invocationOptions = [.manuallyStart, .manuallyStop]
        return options
    }

    private var metrics: [XCTMetric] {
        [XCTClockMetric(), XCTCPUMetric(application: app), XCTMemoryMetric(application: app)]
    }

    private func relaunch() {
        if app.state != .notRunning { app.terminate() }
        app.launch()
    }

    // Launch until today's entries are on screen (includes filling the store, identical on every branch).
    func test_Perf_LaunchToTodayEntries() throws {
        measure(metrics: metrics, options: options) {
            relaunch()
            XCTAssertTrue(app.staticTexts["RecordText_0"].waitForExistence(timeout: 30))
        }
    }

    // Open the calendar and page back through a year of months.
    func test_Perf_OpenCalendarAndScrollBack() throws {
        measure(metrics: metrics, options: manualOptions) {
            relaunch()
            let header = app.buttons["HeaderToggleButton"]
            XCTAssertTrue(header.waitForExistence(timeout: 30))
            startMeasuring()
            header.tap()
            let calendarScroll = app.scrollViews.firstMatch
            XCTAssertTrue(calendarScroll.waitForExistence(timeout: 10))
            for _ in 0..<12 { calendarScroll.swipeDown() }
            stopMeasuring()
        }
    }

    // Open Insights and step back through six months.
    func test_Perf_InsightsMonthSwitching() throws {
        measure(metrics: metrics, options: manualOptions) {
            relaunch()
            let insightsButton = app.buttons["InsightsButton_Inactive"]
            XCTAssertTrue(insightsButton.waitForExistence(timeout: 30))
            startMeasuring()
            insightsButton.tap()
            XCTAssertTrue(app.staticTexts["Joys"].waitForExistence(timeout: 10))
            let previous = app.buttons["PreviousMonthButton"]
            for _ in 0..<6 { previous.tap() }
            stopMeasuring()
        }
    }

    // Pick past days from the open calendar, so the selected day's list is re-fetched each time.
    func test_Perf_SwitchingSelectedDay() throws {
        measure(metrics: metrics, options: manualOptions) {
            relaunch()
            let header = app.buttons["HeaderToggleButton"]
            XCTAssertTrue(header.waitForExistence(timeout: 30))
            startMeasuring()
            for daysAgo in [3, 40, 100] {
                header.tap()
                let cell = app.buttons["DayCell_\(dateKey(daysAgo: daysAgo))"]
                var swipes = 0
                while !cell.waitForExistence(timeout: 1) && swipes < 12 {
                    app.scrollViews.firstMatch.swipeDown()
                    swipes += 1
                }
                XCTAssertTrue(cell.exists, "Day \(daysAgo) days ago was not found in the calendar")
                cell.tap()
            }
            stopMeasuring()
        }
    }

    private func dateKey(daysAgo: Int) -> String {
        let date = Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date()) ?? Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
