import XCTest

final class RecordInputUITests: XCTestCase {

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

    // MARK: - Tests
    
    // Check default input state
    func test_DefaultStateAndCancel() throws {
        app.tabBars.buttons["New Joy"].tap()
        
        let textEditor = app.textViews["RecordInputTextEditor"]
        XCTAssertTrue(textEditor.waitForExistence(timeout: 2.0), "The input window didn't open")
        
        let cancelButton = app.navigationBackButton
        let saveButton = app.buttons["SaveRecordButton"]
        
        XCTAssertTrue(cancelButton.exists && cancelButton.isEnabled, "Cancel button is unavailable")

        XCTAssertFalse(saveButton.isEnabled, "Save button is available in an empty input field")
        
        cancelButton.tap()
        
        XCTAssertTrue(app.tabBars.buttons["New Joy"].waitForExistence(timeout: 2.0), "The default screen did not open")
        
        XCTAssertFalse(textEditor.exists, "The input window did not close")
    }

    // Chech input state after text field editing
    func test_TypingTextEnablesSaveAndCreatesRecord() throws {
        app.tabBars.buttons["New Joy"].tap()
        
        let textEditor = app.textViews["RecordInputTextEditor"]
        XCTAssertTrue(textEditor.waitForExistence(timeout: 2.0))
        
        let saveButton = app.buttons["SaveRecordButton"]
        
        textEditor.tap()
        let testRecordText = "UI Testing is pure joy!"
        textEditor.typeText(testRecordText)
        
        XCTAssertTrue(saveButton.isEnabled, "Save button did not activate after entering the text")
        
        saveButton.tap()
        
        XCTAssertTrue(app.staticTexts[testRecordText].waitForExistence(timeout: 2.0), "The new entry did not appear on the main screen")
    }

    // Swiping back from New Joy returns to the page it was opened from, and the tab bar comes back
    func test_SwipeBackFromRecordRestoresTabBar() throws {
        app.tabBars.buttons["New Joy"].tap()
        let textEditor = app.textViews["RecordInputTextEditor"]
        XCTAssertTrue(textEditor.waitForExistence(timeout: 2.0))
        XCTAssertFalse(app.tabBars.buttons["Home"].isHittable, "The tab bar should be hidden on the record page")
        textEditor.tap()

        swipeBackFromLeftEdge()

        XCTAssertTrue(app.tabBars.buttons["Home"].waitForExistence(timeout: 2.0), "The tab bar did not come back")
        XCTAssertFalse(textEditor.exists, "The input window did not close")
    }

    // The back button brings the tab bar back as well
    func test_BackButtonFromRecordRestoresTabBar() throws {
        app.tabBars.buttons["New Joy"].tap()
        XCTAssertTrue(app.textViews["RecordInputTextEditor"].waitForExistence(timeout: 2.0))

        app.navigationBackButton.tap()

        XCTAssertTrue(app.tabBars.buttons["Home"].waitForExistence(timeout: 2.0), "The tab bar did not come back")
    }

    // Swiping back from a page pushed on Insights returns to Insights, with the tab bar
    func test_SwipeBackFromAllJoysRestoresTabBar() throws {
        app.tabBars.buttons["Insights"].tap()
        let showAll = app.buttons["SeeAllJoysButton"]
        XCTAssertTrue(showAll.waitForExistence(timeout: 2.0))
        showAll.tap()
        XCTAssertTrue(app.navigationBars.firstMatch.waitForExistence(timeout: 2.0))

        swipeBackFromLeftEdge()

        XCTAssertTrue(app.tabBars.buttons["Insights"].waitForExistence(timeout: 2.0), "The tab bar did not come back")
        XCTAssertTrue(app.buttons["SeeAllJoysButton"].waitForExistence(timeout: 2.0), "Insights did not reappear")
    }

    private func swipeBackFromLeftEdge() {
        let start = app.coordinate(withNormalizedOffset: CGVector(dx: 0.0, dy: 0.5))
        let end = app.coordinate(withNormalizedOffset: CGVector(dx: 0.8, dy: 0.5))
        start.press(forDuration: 0.1, thenDragTo: end)
    }
}
