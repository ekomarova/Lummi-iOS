import XCTest

final class RecordButtonUITests: XCTestCase {

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
    
    // Check the record creation on the default screen
    func test_RecordOnDefaultScreen() throws {
        let recordText = "Hello from default screen!"
        createRecord(withText: recordText)

        XCTAssertTrue(app.tabItem("Home", identifier: "HomeButton").waitForExistence(timeout: 5.0))
        XCTAssertTrue(app.tabItem("Home", identifier: "HomeButton").isTabSelected, "Home tab is not selected after saving the record")
        XCTAssertTrue(app.staticTexts[recordText].waitForExistence(timeout: 5.0), "There is no record on the default screen")

    }

    // MARK: - Helpers
    
    private func createRecord(withText text: String) {
        let mainRecordBtn = app.tabItem("New Joy", identifier: "MainRecordButton")
        XCTAssertTrue(mainRecordBtn.waitForExistence(timeout: 5.0))
        mainRecordBtn.tap()

        let textEditor = app.textViews["RecordInputTextEditor"]
        XCTAssertTrue(textEditor.waitForExistence(timeout: 5.0), "The text input field did not open")

        textEditor.tap()
        textEditor.typeText(text)

        let saveBtn = app.buttons["SaveRecordButton"]
        saveBtn.tap()

        XCTAssertTrue(textEditor.waitForNonExistence(timeout: 5.0), "The text input field did not close after saving")
    }
}
