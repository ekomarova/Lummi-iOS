import XCTest

final class InsightsUITests: XCTestCase {
    
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
    
    // MARK: - Default tests
    
    // Check the button color change
    func test_InsightsButtonChangesState() throws {
        launchApp(with: [""])
        let inactiveInsightsBtn = app.buttons["InsightsButton_Inactive"]
        XCTAssertTrue(inactiveInsightsBtn.waitForExistence(timeout: 2.0), "Insights button was not found")
        
        inactiveInsightsBtn.tap()
        
        let activeInsightsBtn = app.buttons["InsightsButton_Active"]
        XCTAssertTrue(activeInsightsBtn.waitForExistence(timeout: 2.0), "Insights button did not become active after pressing")
    }
    
    // Check Insights header existence
    func test_InsightsTitleExists() throws {
        launchApp(with: [""])
        app.buttons["InsightsButton_Inactive"].tap()
        
        let title = app.staticTexts["Insights"]
        XCTAssertTrue(title.waitForExistence(timeout: 2.0), "Insights header did not appear on the screen.")
    }
    
    // Check Joys/Day streak/Joyful hours existence
    func test_InsightsDefaulEmptyCheckView() throws {
        launchApp(with: [""])
        app.buttons["InsightsButton_Inactive"].tap()

        XCTAssertTrue(app.staticTexts["Joys"].waitForExistence(timeout: 2.0))
        XCTAssertTrue(app.staticTexts["Day Streak"].waitForExistence(timeout: 2.0))
        XCTAssertTrue(app.staticTexts["Joyful Hours"].waitForExistence(timeout: 2.0))
    }

    // Recall / Show All Joys stay available even when the month has no joys
    func test_InsightsRecallIsShownForEmptyMonth() throws {
        launchApp(with: [""])
        app.buttons["InsightsButton_Inactive"].tap()

        XCTAssertTrue(app.staticTexts["Recall"].waitForExistence(timeout: 2.0))
        let showAll = app.staticTexts["Show All Joys"]
        XCTAssertTrue(showAll.waitForExistence(timeout: 2.0))
        showAll.tap()

        let backButton = app.buttons["AllJoysBackButton"]
        XCTAssertTrue(backButton.waitForExistence(timeout: 2.0))
        backButton.tap()
        XCTAssertTrue(app.staticTexts["Show All Joys"].waitForExistence(timeout: 2.0))
    }

    // MARK: - Other tests
    
    // Check all data on the Insight tab
    func test_InsightsWithFourDaysFilled() throws {
        launchApp(with: ["-UI_TESTING_4_DAYS_FILLED"])
        // iPhone SE (667 pt tall) keeps this element under the bottom toolbar, so the tap misses it
        try XCTSkipIf(app.isSmallScreen, "Not supported on small screens (iPhone SE)")

        let inactiveInsightsBtn = app.buttons["InsightsButton_Inactive"]
        XCTAssertTrue(inactiveInsightsBtn.waitForExistence(timeout: 2.0))
        inactiveInsightsBtn.tap()

        let fours = app.staticTexts.matching(NSPredicate(format: "label == '4'"))
        XCTAssertTrue(fours.count >= 2, "Expected to find the number '4' for Joys and Day Streak")

        let timePredicate = NSPredicate(format: "label CONTAINS '8:00' AND label CONTAINS '11:00'")
        let joyfulHoursTime = app.staticTexts.matching(timePredicate).firstMatch
        XCTAssertTrue(joyfulHoursTime.waitForExistence(timeout: 2.0), "The time of 'Joyful Hours' does not match the expected range")

        let expandButtonText = app.staticTexts["Show All Joys"]
        XCTAssertTrue(expandButtonText.waitForExistence(timeout: 2.0))
        expandButtonText.tap()

        for index in 1...4 {
            let momentText = app.staticTexts["Evening mock moment \(index)"]
            XCTAssertTrue(momentText.waitForExistence(timeout: 2.0), "Recording 'Evening mock moment \(index)' did not appear on the list")
        }
    }

    // Insights has no month switcher: it shows the current month's Joys count and entries only
    func test_InsightsShowsOnlyCurrentMonthData() throws {
        launchApp(with: ["-UI_TESTING_INSIGHTS_TWO_MONTHS"])
        try XCTSkipIf(app.isSmallScreen, "Not supported on small screens (iPhone SE)")

        let inactiveInsightsBtn = app.buttons["InsightsButton_Inactive"]
        XCTAssertTrue(inactiveInsightsBtn.waitForExistence(timeout: 2.0))
        inactiveInsightsBtn.tap()

        XCTAssertTrue(app.staticTexts["2"].waitForExistence(timeout: 2.0), "Current month should show 2 joys")
        XCTAssertFalse(app.buttons["PreviousMonthButton"].exists, "The month switcher should be gone")
        XCTAssertFalse(app.buttons["NextMonthButton"].exists, "The month switcher should be gone")
        assertAllJoys(prefix: "Current month joy", shown: 2, hidden: "Previous month joy")
    }

    // Opens "All Joys" for the current month, checks its entries, and returns to the Insights screen
    private func assertAllJoys(prefix: String, shown: Int, hidden hiddenPrefix: String) {
        let showAll = app.staticTexts["Show All Joys"]
        XCTAssertTrue(showAll.waitForExistence(timeout: 2.0))
        showAll.tap()

        for index in 1...shown {
            XCTAssertTrue(app.staticTexts["\(prefix) \(index)"].waitForExistence(timeout: 2.0), "\(prefix) \(index) is missing")
        }
        XCTAssertFalse(app.staticTexts["\(prefix) \(shown + 1)"].exists, "More entries than expected are listed")
        XCTAssertFalse(app.staticTexts["\(hiddenPrefix) 1"].exists, "An entry of another month is listed")

        app.buttons["AllJoysBackButton"].tap()
        XCTAssertTrue(app.staticTexts["Show All Joys"].waitForExistence(timeout: 2.0))
    }
}
