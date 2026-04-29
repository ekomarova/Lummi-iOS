import XCTest

final class TodayRecordsUITests: XCTestCase {

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
    
    // Check multiple records creation
    func test_CreateMultipleRecordsAndScroll() throws {
        let numberOfRecords = 10
        
        for i in 0..<numberOfRecords {
            createRecord(withText: "Record #\(i)")
            let indexRecord = app.staticTexts["RecordText_\(i)"]
            XCTAssertTrue(indexRecord.waitForExistence(timeout: 2.0), "Entry #\(i) has not been added")
        }
        
        // Check scroll
        let calendarScroll = app.scrollViews.firstMatch
        calendarScroll.swipeUp()
        calendarScroll.swipeUp()
        
        let lastRecord = app.staticTexts["RecordText_\(numberOfRecords - 1)"]
        XCTAssertTrue(lastRecord.exists, "Couldn't scroll to the last entry")

        calendarScroll.swipeDown()
        calendarScroll.swipeDown()
    }

    func test_EditRecord() throws {
        let numberOfRecords = 10
        
        for i in 0..<numberOfRecords {
            createRecord(withText: "Record #\(i)")
        }

        let originalText = "Record #8"
        let addedText = "(edited)"

        let recordToEdit = app.staticTexts["RecordText_8"]
        XCTAssertTrue(recordToEdit.waitForExistence(timeout: 2.0))
        
        recordToEdit.press(forDuration: 1.0)
        
        let editButton = app.buttons["EditRecordButton"]
        XCTAssertTrue(editButton.waitForExistence(timeout: 2.0))
        editButton.tap()
        
        let inlineTextField = app.textFields["EditRecordTextField"]
        XCTAssertTrue(inlineTextField.waitForExistence(timeout: 2.0), "The editing field did not appear")
        
        inlineTextField.tap()
        inlineTextField.typeText(addedText)
        
        app.otherElements["GlobalDismissArea"].firstMatch.tap()
        
        let updatedText = originalText + addedText
        XCTAssertTrue(app.staticTexts[updatedText].waitForExistence(timeout: 2.0), "The edited entry did not appear")
    }

    func test_DeleteRecord() throws {
        let numberOfRecords = 10
        
        for i in 0..<numberOfRecords {
            createRecord(withText: "Record #\(i)")
        }
        
        let recordToDelete = app.staticTexts["RecordText_7"]
        
        recordToDelete.press(forDuration: 1.0)
        
        let deleteButton = app.buttons["DeleteRecordButton"]
        XCTAssertTrue(deleteButton.waitForExistence(timeout: 2.0))
        deleteButton.tap()
        
        XCTAssertFalse(app.staticTexts["Record #7"].exists, "The entry was not deleted from the list")
    }

    // MARK: - Helpers
    
    private func createRecord(withText text: String) {
        app.buttons["MainRecordButton"].tap()
        
        let textEditor = app.textViews["RecordInputTextEditor"]
        XCTAssertTrue(textEditor.waitForExistence(timeout: 2.0))
        
        textEditor.tap()
        textEditor.typeText(text)
        
        app.buttons["SaveRecordButton"].tap()
    }
}
