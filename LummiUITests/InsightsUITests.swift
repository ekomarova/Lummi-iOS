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
        
        let title = app.staticTexts["Insights".uppercased()]
        XCTAssertTrue(title.waitForExistence(timeout: 2.0), "Insights header did not appear on the screen.")
    }
    
    // MARK: - Current month state tests

    // Check month state w/o entries
    func test_CurrentMonth_ZeroState() throws {
        launchApp(with: [""])
        app.buttons["InsightsButton_Inactive"].tap()
        
        let joysMessage = app.staticTexts["MonthlyJoysMessage"]
        let streakMessage = app.staticTexts["MonthlyStreakMessage"]
        let comparisonMessage = app.staticTexts["MonthlyComparisonMessage"]
        
        XCTAssertTrue(joysMessage.waitForExistence(timeout: 2.0))
        XCTAssertEqual(joysMessage.label, "Your journey of joy starts here. Record a moment to begin!")
        XCTAssertEqual(streakMessage.label, "Ready for some joy? Record a moment today to start your streak!")
        XCTAssertEqual(comparisonMessage.label, "The beginning of a beautiful story! Let's see how many bright moments this month brings")
    }
    
    // Check month state with 1 entry
    func test_CurrentMonth_FewJoys_OneDayStreak() throws {
        launchApp(with: ["-UI_TESTING_CALENDAR"])
        app.buttons["InsightsButton_Inactive"].tap()
        
        let joysMessage = app.staticTexts["MonthlyJoysMessage"]
        let streakMessage = app.staticTexts["MonthlyStreakMessage"]
        let comparisonMessage = app.staticTexts["MonthlyComparisonMessage"]
        
        XCTAssertTrue(joysMessage.waitForExistence(timeout: 2.0))
        XCTAssertEqual(joysMessage.label, "Beautiful moments collected so far! Keep your eyes open for more!")
        XCTAssertEqual(streakMessage.label, "Day of joy down! Come back tomorrow to keep it going")
        XCTAssertEqual(comparisonMessage.label, "Wonderful consistency! You continue to find joy in your familiar rhythm")
    }
    
    // Check month state with many entry
    func test_CurrentMonth_ManyJoys_MultipleDaysStreak() throws {
        launchApp(with: ["-UI_TESTING_CALENDAR", "-UI_TESTING_10_RECORDS"])
        app.buttons["InsightsButton_Inactive"].tap()
        
        let joysMessage = app.staticTexts["MonthlyJoysMessage"]
        let streakMessage = app.staticTexts["MonthlyStreakMessage"]
        let comparisonMessage = app.staticTexts["MonthlyComparisonMessage"]
        
        XCTAssertTrue(joysMessage.waitForExistence(timeout: 2.0))
        XCTAssertEqual(joysMessage.label, "Beautiful moments experienced so far! Look at you go!")
        XCTAssertEqual(streakMessage.label, "Days of joy in a row! Keep this beautiful momentum going!")
        XCTAssertEqual(comparisonMessage.label, "Your ability to notice joy is growing! You have more moments this month than the last")
    }
    
    // Check month state with fewer entries than past month
        func test_CurrentMonth_FewerJoysThanPastMonth() throws {
            launchApp(with: ["-UI_TESTING_CALENDAR", "-UI_TESTING_PAST_MONTH_MANY_JOYS"])
            app.buttons["InsightsButton_Inactive"].tap()
            
            let comparisonMessage = app.staticTexts["MonthlyComparisonMessage"]
            XCTAssertTrue(comparisonMessage.waitForExistence(timeout: 2.0))
            
            XCTAssertEqual(comparisonMessage.label, "Every saved moment matters! You are continuing your collection of joy!")
        }
    
    // MARK: - Past months state tests
    
    // Chech month state w/o entries
    func test_PastMonth_ZeroState() throws {
        launchApp(with: ["-UI_TESTING_PAST_MONTHS_AVAILABLE"])
        app.buttons["InsightsButton_Inactive"].tap()
        
        let prevButton = app.buttons["PreviousMonthButton"]
        XCTAssertTrue(prevButton.waitForExistence(timeout: 2.0))
        prevButton.tap()
        
        let joysMessage = app.staticTexts["MonthlyJoysMessage"]
        let streakMessage = app.staticTexts["MonthlyStreakMessage"]
        let comparisonMessage = app.staticTexts["MonthlyComparisonMessage"]
        
        XCTAssertEqual(joysMessage.label, "A quiet month with no recorded moments")
        XCTAssertEqual(streakMessage.label, "No daily streaks were built this month")
        XCTAssertEqual(comparisonMessage.label, "Your journal is ready for new entries. What joy will happen today?")
    }
    
    // Check month state with 1 entry
    func test_PastMonth_FewJoys_OneDayStreak() throws {
        launchApp(with: ["-UI_TESTING_PAST_MONTH_ONE_JOY"])
        app.buttons["InsightsButton_Inactive"].tap()
        
        app.buttons["PreviousMonthButton"].tap()
        
        let joysMessage = app.staticTexts["MonthlyJoysMessage"]
        let streakMessage = app.staticTexts["MonthlyStreakMessage"]
        let comparisonMessage = app.staticTexts["MonthlyComparisonMessage"]
        
        XCTAssertEqual(joysMessage.label, "Beautiful moments collected during this month")
        XCTAssertEqual(streakMessage.label, "Day of joy found. Every moment counts!")
        XCTAssertEqual(comparisonMessage.label, "The beginning of a beautiful story! Let's see how many bright moments this month brings")
    }
    
    // Check month state with many entry
    func test_PastMonth_ManyJoys_MultipleDaysStreak() throws {
        launchApp(with: ["-UI_TESTING_PAST_MONTH_MANY_JOYS"])
        app.buttons["InsightsButton_Inactive"].tap()
        
        app.buttons["PreviousMonthButton"].tap()
        
        let joysMessage = app.staticTexts["MonthlyJoysMessage"]
        let streakMessage = app.staticTexts["MonthlyStreakMessage"]
        let comparisonMessage = app.staticTexts["MonthlyComparisonMessage"]
        
        XCTAssertEqual(joysMessage.label, "Beautiful moments collected during this month")
        XCTAssertEqual(streakMessage.label, "Days of joy in a row! That was your best streak")
        XCTAssertEqual(comparisonMessage.label, "The beginning of a beautiful story! Let's see how many bright moments this month brings")
    }
}
