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
        
        XCTAssertTrue(app.staticTexts["Joys".uppercased()].waitForExistence(timeout: 2.0))
        XCTAssertTrue(app.staticTexts["Day streak".uppercased()].waitForExistence(timeout: 2.0))
        XCTAssertTrue(app.staticTexts["CompMsg_First"].waitForExistence(timeout: 2.0))
    }
    
    // Check month state with 1 entry
    func test_CurrentMonth_FewJoys_OneDayStreak() throws {
        launchApp(with: ["-UI_TESTING_CALENDAR"])
        app.buttons["InsightsButton_Inactive"].tap()
        
        XCTAssertTrue(app.staticTexts["Joys".uppercased()].waitForExistence(timeout: 2.0))
        XCTAssertTrue(app.staticTexts["Day streak".uppercased()].waitForExistence(timeout: 2.0))
        XCTAssertTrue(app.staticTexts["CompMsg_Stability"].waitForExistence(timeout: 2.0))
    }
    
    // Check month state with many entry
    func test_CurrentMonth_ManyJoys_MultipleDaysStreak() throws {
        launchApp(with: ["-UI_TESTING_CALENDAR", "-UI_TESTING_10_RECORDS"])
        app.buttons["InsightsButton_Inactive"].tap()
        
        XCTAssertTrue(app.staticTexts["Joys".uppercased()].waitForExistence(timeout: 2.0))
        XCTAssertTrue(app.staticTexts["Day streak".uppercased()].waitForExistence(timeout: 2.0))
        XCTAssertTrue(app.staticTexts["CompMsg_Growth"].waitForExistence(timeout: 2.0))
    }
    
    // Check month state with fewer entries than past month
    func test_CurrentMonth_FewerJoysThanPastMonth() throws {
        launchApp(with: ["-UI_TESTING_CALENDAR", "-UI_TESTING_PAST_MONTH_MANY_JOYS"])
        app.buttons["InsightsButton_Inactive"].tap()
        
        XCTAssertTrue(app.staticTexts["CompMsg_Decline"].waitForExistence(timeout: 2.0))
    }
    
    // MARK: - Past months state tests
    
    // Chech month state w/o entries
    func test_PastMonth_ZeroState() throws {
        launchApp(with: ["-UI_TESTING_PAST_MONTHS_AVAILABLE"])
        app.buttons["InsightsButton_Inactive"].tap()
        app.buttons["PreviousMonthButton"].tap()
                
        XCTAssertTrue(app.staticTexts["Joys".uppercased()].waitForExistence(timeout: 2.0))
        XCTAssertTrue(app.staticTexts["Day streak".uppercased()].waitForExistence(timeout: 2.0))
        XCTAssertTrue(app.staticTexts["CompMsg_Zero"].waitForExistence(timeout: 2.0))
    }
    
    // Check month state with 1 entry
    func test_PastMonth_FewJoys_OneDayStreak() throws {
        launchApp(with: ["-UI_TESTING_PAST_MONTH_ONE_JOY"])
        app.buttons["InsightsButton_Inactive"].tap()
        app.buttons["PreviousMonthButton"].tap()
                
        XCTAssertTrue(app.staticTexts["Joys".uppercased()].waitForExistence(timeout: 2.0))
        XCTAssertTrue(app.staticTexts["Day streak".uppercased()].waitForExistence(timeout: 2.0))
        XCTAssertTrue(app.staticTexts["CompMsg_First"].waitForExistence(timeout: 2.0))
    }
    
    // Check month state with many entry
    // Borderline case (fails for the first days of the month)
    func test_PastMonth_ManyJoys_MultipleDaysStreak() throws {
        launchApp(with: ["-UI_TESTING_PAST_MONTH_MANY_JOYS"])
        app.buttons["InsightsButton_Inactive"].tap()
        app.buttons["PreviousMonthButton"].tap()
                
        XCTAssertTrue(app.staticTexts["Joys".uppercased()].waitForExistence(timeout: 2.0))
        XCTAssertTrue(app.staticTexts["Day streak".uppercased()].waitForExistence(timeout: 2.0))
        XCTAssertTrue(app.staticTexts["CompMsg_First"].waitForExistence(timeout: 2.0))
    }
}
