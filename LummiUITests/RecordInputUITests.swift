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
        app.tabItem("New Joy", identifier: "MainRecordButton").tap()
        
        let textEditor = app.textViews["RecordInputTextEditor"]
        XCTAssertTrue(textEditor.waitForExistence(timeout: 2.0), "The input window didn't open")
        
        let cancelButton = app.navigationBackButton
        let saveButton = app.buttons["SaveRecordButton"]
        
        XCTAssertTrue(cancelButton.exists && cancelButton.isEnabled, "Cancel button is unavailable")

        XCTAssertFalse(saveButton.isEnabled, "Save button is available in an empty input field")
        
        cancelButton.tap()
        
        XCTAssertTrue(app.tabItem("New Joy", identifier: "MainRecordButton").waitForExistence(timeout: 2.0), "The default screen did not open")
        
        XCTAssertFalse(textEditor.exists, "The input window did not close")
    }

    // Chech input state after text field editing
    func test_TypingTextEnablesSaveAndCreatesRecord() throws {
        app.tabItem("New Joy", identifier: "MainRecordButton").tap()
        
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
        app.tabItem("New Joy", identifier: "MainRecordButton").tap()
        let textEditor = app.textViews["RecordInputTextEditor"]
        XCTAssertTrue(textEditor.waitForExistence(timeout: 2.0))
        XCTAssertFalse(app.tabItem("Home", identifier: "HomeButton").isHittable, "The tab bar should be hidden on the record page")
        textEditor.tap()

        swipeBackFromLeftEdge()

        XCTAssertTrue(app.tabItem("Home", identifier: "HomeButton").waitForExistence(timeout: 2.0), "The tab bar did not come back")
        XCTAssertFalse(textEditor.exists, "The input window did not close")
    }

    // The back button brings the tab bar back as well
    func test_BackButtonFromRecordRestoresTabBar() throws {
        app.tabItem("New Joy", identifier: "MainRecordButton").tap()
        XCTAssertTrue(app.textViews["RecordInputTextEditor"].waitForExistence(timeout: 2.0))

        app.navigationBackButton.tap()

        XCTAssertTrue(app.tabItem("Home", identifier: "HomeButton").waitForExistence(timeout: 2.0), "The tab bar did not come back")
    }

    // Swiping back from a page pushed on Insights returns to Insights, with the tab bar
    func test_SwipeBackFromAllJoysRestoresTabBar() throws {
        app.tabItem("Insights", identifier: "InsightsButton").tap()
        let showAll = app.buttons["SeeAllJoysButton"]
        XCTAssertTrue(showAll.waitForExistence(timeout: 2.0))
        showAll.tap()
        XCTAssertTrue(app.navigationBars.firstMatch.waitForExistence(timeout: 2.0))

        swipeBackFromLeftEdge()

        XCTAssertTrue(app.tabItem("Insights", identifier: "InsightsButton").waitForExistence(timeout: 2.0), "The tab bar did not come back")
        XCTAssertTrue(app.buttons["SeeAllJoysButton"].waitForExistence(timeout: 2.0), "Insights did not reappear")
    }

    // On iPad the tab bar floats at the top and is not a `tabBars` element. New Joy opens from it, and going back must
    // bring the tab bar back (it was lost with the sidebar, which is why the sidebar is off)
    func test_RecordPageOpensAndClosesOnIPad() throws {
        try XCTSkipUnless(UIDevice.current.userInterfaceIdiom == .pad, "The floating tab bar exists only on iPad")
        let recordButton = app.descendants(matching: .any).matching(identifier: "MainRecordButton").firstMatch
        XCTAssertTrue(recordButton.waitForExistence(timeout: 2.0), "The New Joy item is missing")
        recordButton.tap()

        XCTAssertTrue(app.textViews["RecordInputTextEditor"].waitForExistence(timeout: 3.0), "The input window didn't open")
        XCTAssertTrue(app.buttons["SaveRecordButton"].exists, "The save button is missing")

        app.navigationBackButton.tap()

        let home = app.descendants(matching: .any).matching(NSPredicate(format: "identifier BEGINSWITH 'HomeButton'")).firstMatch
        XCTAssertTrue(home.waitForExistence(timeout: 3.0), "The tab bar did not come back")
        XCTAssertEqual(app.state, .runningForeground, "The app crashed")
    }

    private func swipeBackFromLeftEdge() {
        let start = app.coordinate(withNormalizedOffset: CGVector(dx: 0.0, dy: 0.5))
        let end = app.coordinate(withNormalizedOffset: CGVector(dx: 0.8, dy: 0.5))
        start.press(forDuration: 0.1, thenDragTo: end)
    }
}
