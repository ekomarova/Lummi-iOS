import XCTest

final class RecordButtonUITests: XCTestCase {

    var app: XCUIApplication!
    
    let today = Date()
    var past32Date: Date { Calendar.current.date(byAdding: .day, value: -32, to: today) ?? today }
    var future1Date: Date { Calendar.current.date(byAdding: .day, value: 1, to: today) ?? today }

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

        XCTAssertTrue(app.buttons["HomeButton_Active"].waitForExistence(timeout: 5.0))
        XCTAssertTrue(app.staticTexts[recordText].waitForExistence(timeout: 5.0), "There is no record on the default screen")

        verifyStarOnTodayInCalendar()
    }

    // Check the record creation on the past date screen
    func test_RecordWhileViewingPastDate() throws {
        let recordText = "Hello from the past!"
        
        app.buttons["HeaderToggleButton"].tap()

        let calendarScroll = app.scrollViews.firstMatch
        calendarScroll.swipeDown()
        calendarScroll.swipeDown()
        calendarScroll.swipeDown()

        app.buttons["DayCell_\(dateKey(for: past32Date))"].tap()
        
        createRecord(withText: recordText)

        XCTAssertFalse(app.staticTexts[recordText].exists, "The record of the current day is displayed on the past day screen")
        
        app.buttons["HomeButton_Inactive"].tap()
        
        XCTAssertTrue(app.staticTexts[recordText].exists, "There is no record on the default screen")
        
        verifyStarOnTodayInCalendar()
    }

    // Check the record creation on the future date screen
    func test_RecordWhileViewingFutureDate() throws {
        let recordText = "Hello from the future!"
        
        app.buttons["HeaderToggleButton"].tap()

        let futureDayCell = app.buttons["DayCell_\(dateKey(for: future1Date))"]
        if futureDayCell.waitForExistence(timeout: 2.0) {
            futureDayCell.tap()
            XCTAssertTrue(app.staticTexts["Oops! This day has not started yet"].exists)
        }

        createRecord(withText: recordText)

        XCTAssertTrue(app.staticTexts["Oops! This day has not started yet"].exists)
        XCTAssertFalse(app.staticTexts[recordText].exists)
        
        app.buttons["HomeButton_Inactive"].tap()
        
        XCTAssertTrue(app.staticTexts[recordText].exists, "There is no record on the default screen")
        
        verifyStarOnTodayInCalendar()
    }

    // MARK: - Helpers
    
    private func createRecord(withText text: String) {
        let mainRecordBtn = app.buttons["MainRecordButton"]
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
    
    private func verifyStarOnTodayInCalendar() {
        let headerBtn = app.buttons["HeaderToggleButton"]
        headerBtn.tap()
        
        let todayKey = dateKey(for: today)
        let todayCell = app.buttons["DayCell_\(todayKey)"]
        
        XCTAssertTrue(todayCell.waitForExistence(timeout: 2.0), "The calendar didn't open")
        
        XCTAssertEqual(todayCell.value as? String, "Filled", "The star has not appeared today.")
        
        headerBtn.tap()
    }

    private func dateKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
