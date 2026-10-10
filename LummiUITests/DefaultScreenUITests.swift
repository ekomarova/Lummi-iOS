import XCTest

final class DefaultScreenUITests: XCTestCase {
    
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Tests
    
    func test_CurrentDateOnLaunch() throws {
        verifyCurrentDate()
    }
    
    func test_HomeButtonIsActive() throws {
        verifyHomeButton()
    }
    
    func test_EmptyRecordsState() throws {
        verifyRecords()
    }
    
    func test_CalendarIsCollapsed() throws {
        verifyCalendarCollapsed()
    }
    
    func test_AllDefaultStatesTogether() throws {
        verifyCurrentDate()
        verifyHomeButton()
        verifyRecords()
        verifyCalendarCollapsed()
    }
    
    // MARK: - Helpers
    
    private func verifyCurrentDate() {
        let headerButton = app.buttons["HeaderToggleButton"]

        XCTAssertTrue(headerButton.waitForExistence(timeout: 5.0), "No Header text date on the screen")
        
        let today = Date()
        let month = today.formatted(.dateTime.month(.wide))
        let day = Calendar.current.component(.day, from: today)
        let expectedDateString = "\(day) \(month)"
        
        XCTAssertEqual(headerButton.label, expectedDateString, "Header does not display today's date")
    }
    
    private func verifyHomeButton() {
        XCTAssertTrue(app.tabBars.buttons["Home"].waitForExistence(timeout: 5.0), "Home tab is missing when launching the application")
        XCTAssertTrue(app.tabBars.buttons["Home"].isSelected, "Home tab is not selected when launching the application")
    }

    private func verifyRecords() {
        let noRecordsText = app.staticTexts["No records for this day"]
        XCTAssertTrue(noRecordsText.waitForExistence(timeout: 5.0), "There is no label w/o record")
    }
    
    private func verifyCalendarCollapsed() {
        let todayCell = app.buttons["DayCell_\(Date().uiTestDateKey)"]
        XCTAssertFalse(todayCell.exists, "The calendar is not collapsed")
    }
}
