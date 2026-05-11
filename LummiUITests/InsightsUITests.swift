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
    
    // Check Joys/Day streak/Joyful hours existence
    func test_InsightsDefaulEmptyCheckView() throws {
        launchApp(with: [""])
        app.buttons["InsightsButton_Inactive"].tap()

        XCTAssertTrue(app.staticTexts["Joys".uppercased()].waitForExistence(timeout: 2.0))
        XCTAssertTrue(app.staticTexts["Day streak".uppercased()].waitForExistence(timeout: 2.0))
        XCTAssertTrue(app.staticTexts["Joyful hours".uppercased()].waitForExistence(timeout: 2.0))
    }
    
    // MARK: - Other tests
    
    // Check all data on the Insight tab
    func test_InsightsWithFourDaysFilled() throws {
        launchApp(with: ["-UI_TESTING_4_DAYS_FILLED"])

        let inactiveInsightsBtn = app.buttons["InsightsButton_Inactive"]
        XCTAssertTrue(inactiveInsightsBtn.waitForExistence(timeout: 2.0))
        inactiveInsightsBtn.tap()

        let fours = app.staticTexts.matching(NSPredicate(format: "label == '4'"))
        XCTAssertTrue(fours.count >= 2, "Expected to find the number '4' for Joys and Day Streak")

        let timePredicate = NSPredicate(format: "label CONTAINS '8:00' AND label CONTAINS '10:00'")
        let joyfulHoursTime = app.staticTexts.matching(timePredicate).firstMatch
        XCTAssertTrue(joyfulHoursTime.waitForExistence(timeout: 2.0), "The time of 'Joyful Hours' does not match the expected range")

        let expandButtonText = app.staticTexts["Want to see all moments?".uppercased()]
        XCTAssertTrue(expandButtonText.waitForExistence(timeout: 2.0))
        expandButtonText.tap()

        for i in 1...4 {
            let momentText = app.staticTexts["Evening mock moment \(i)"]
            XCTAssertTrue(momentText.waitForExistence(timeout: 2.0), "Recording 'Evening mock moment \(i)' did not appear on the list")
        }
    }
}
