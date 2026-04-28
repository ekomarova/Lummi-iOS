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
        app.buttons["MainRecordButton"].tap()
        
        let textEditor = app.textViews["RecordInputTextEditor"]
        XCTAssertTrue(textEditor.waitForExistence(timeout: 2.0), "The input window didn't open")
        
        let cancelButton = app.buttons["CancelRecordButton"]
        let saveButton = app.buttons["SaveRecordButton"]
        
        XCTAssertTrue(cancelButton.exists && cancelButton.isEnabled, "Cancel button is unavailable")

        XCTAssertFalse(saveButton.isEnabled, "Save button is available in an empty input field")
        
        cancelButton.tap()
        
        XCTAssertTrue(app.buttons["MainRecordButton"].waitForExistence(timeout: 2.0), "The default screen did not open")
        
        XCTAssertFalse(textEditor.exists, "The input window did not close")
    }

    // Chech input state after text filed editing
    func test_TypingTextEnablesSaveAndCreatesRecord() throws {
        app.buttons["MainRecordButton"].tap()
        
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
}
