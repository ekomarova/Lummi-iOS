import XCTest

final class InsightsUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["-UI_TESTING_CALENDAR"]
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - Default tests
    
    // Check the button color change
    func test_InsightsButtonChangesState() throws {
        let inactiveInsightsBtn = app.buttons["InsightsButton_Inactive"]
        XCTAssertTrue(inactiveInsightsBtn.waitForExistence(timeout: 2.0), "Insights button was not found")
        
        inactiveInsightsBtn.tap()
        
        let activeInsightsBtn = app.buttons["InsightsButton_Active"]
        XCTAssertTrue(activeInsightsBtn.waitForExistence(timeout: 2.0), "Insights button did not become active after pressing")
    }
    
    // Check Insights header existence
    func test_InsightsTitleExists() throws {
        app.buttons["InsightsButton_Inactive"].tap()
        
        let title = app.staticTexts["INSIGHTS"]
        XCTAssertTrue(title.waitForExistence(timeout: 2.0), "Insights header did not appear on the screen.")
    }
}
