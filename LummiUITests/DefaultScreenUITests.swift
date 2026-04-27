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
            
        XCTAssertTrue(headerButton.waitForExistence(timeout: 2.0), "No Header text date on the screen")
        
        let today = Date()
        let month = today.formatted(.dateTime.month(.wide)).uppercased()
        let year = today.formatted(.dateTime.year())
        let day = Calendar.current.component(.day, from: today)
        let expectedDateString = "\(day) \(month) \(year)"
        
        XCTAssertEqual(headerButton.label, expectedDateString, "Header does not display today's date")
    }
    
    private func verifyHomeButton() {
        let activeHomeButton = app.buttons["HomeButton_Active"]
        XCTAssertTrue(activeHomeButton.waitForExistence(timeout: 2.0), "Home button is not filled in when launching the application")
    }
    
    private func verifyRecords() {
        let noRecordsText = app.staticTexts["No records for this day"]
        XCTAssertTrue(noRecordsText.exists, "There is no label w/o record")
    }
    
    private func verifyCalendarCollapsed() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let todayKey = formatter.string(from: Date())
        
        let todayCell = app.buttons["DayCell_\(todayKey)"]
        XCTAssertFalse(todayCell.exists, "The calendar is not collapsed")
    }
}
