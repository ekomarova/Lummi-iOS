import XCTest

final class CalendarUITests: XCTestCase {

    var app: XCUIApplication!
    
    let today = Date()
    var past32Date: Date { Calendar.current.date(byAdding: .day, value: -32, to: today)! }
    var future1Date: Date { Calendar.current.date(byAdding: .day, value: 1, to: today)! }

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

    // Open the calendar and check the header date format
    func test_ToggleCalendarAndDateFormat() throws {
        let headerBtn = app.buttons["HeaderToggleButton"]
        XCTAssertTrue(headerBtn.waitForExistence(timeout: 2.0))
        
        headerBtn.tap()

        let month = today.formatted(.dateTime.month(.wide))
        let year = today.formatted(.dateTime.year())
        let expectedLabel = "\(month) \(year)"
        let labelPredicate = NSPredicate(format: "label == %@", expectedLabel)
        let labelExpectation = expectation(for: labelPredicate, evaluatedWith: headerBtn, handler: nil)
        wait(for: [labelExpectation], timeout: 5.0)
        XCTAssertEqual(headerBtn.label, expectedLabel, "Incorrect header format for the expanded calendar")
        
        let todayKey = dateKey(for: today)
        let todayCell = app.buttons["DayCell_\(todayKey)"]
        XCTAssertTrue(todayCell.waitForExistence(timeout: 2.0), "The calendar is not expanded")
    }

    // Check the calendar for date: current_date - 32
    func test_PastMonthScrollAndStarRendering() throws {
        let headerBtn = app.buttons["HeaderToggleButton"]
        headerBtn.tap()

        let calendarScroll = app.scrollViews.firstMatch
        calendarScroll.swipeDown()
        calendarScroll.swipeDown()
        calendarScroll.swipeDown()

        let pastMonth = past32Date.formatted(.dateTime.month(.wide))
        let pastYear = past32Date.formatted(.dateTime.year())
        XCTAssertEqual(headerBtn.label, "\(pastMonth) \(pastYear)", "The month is displayed incorrectly")

        let key = dateKey(for: past32Date)
        let pastDayCell = app.buttons["DayCell_\(key)"]
        XCTAssertTrue(pastDayCell.waitForExistence(timeout: 2.0), "Cell 'current_date - 32' does not exist")
        
        XCTAssertEqual(pastDayCell.value as? String, "Filled", "The start is not displayed on the bottom with the entry")
    }

    // Checking a record for date: current_date - 32
    func test_TapPastRecordHidesCalendar() throws {
        app.buttons["HeaderToggleButton"].tap()
        
        let calendarScroll = app.scrollViews.firstMatch
        calendarScroll.swipeDown()
        calendarScroll.swipeDown()
        calendarScroll.swipeDown()
        
        let key = dateKey(for: past32Date)
        let pastDayCell = app.buttons["DayCell_\(key)"]
        XCTAssertTrue(pastDayCell.waitForExistence(timeout: 10.0))
        pastDayCell.tap()
        
        let todayCell = app.buttons["DayCell_\(dateKey(for: today))"]
        XCTAssertFalse(todayCell.exists, "The calendar is expanded")
        
        XCTAssertTrue(app.staticTexts["Watched a beautiful sunset"].exists)
        
        XCTAssertTrue(app.buttons["HomeButton_Inactive"].exists)
    }

    // Check the absence of edit/delete buttons for past recordings
    func test_PastRecordCannotBeEdited() throws {
        try test_TapPastRecordHidesCalendar()
        let recordText = app.staticTexts["Watched a beautiful sunset"]
        recordText.press(forDuration: 1.5)
        
        XCTAssertFalse(app.buttons["pencil"].exists, "The past should not be edited")
        XCTAssertFalse(app.buttons["trash"].exists, "The past should not be deleted")
    }

    // Check Home button state
    func test_HomeButtonReturnsToToday() throws {
        try test_TapPastRecordHidesCalendar()
        
        app.buttons["HomeButton_Inactive"].tap()
        
        XCTAssertTrue(app.buttons["HomeButton_Active"].exists, "Home button is not active")
        let todayCell = app.buttons["DayCell_\(dateKey(for: today))"]
        XCTAssertFalse(todayCell.exists, "The calendar is not collapsed")
    }

    // Each selected day must show its own records, not the ones of the previously selected day
    func test_SwitchingBetweenDaysShowsEachDaysRecords() throws {
        let yesterdayText = app.staticTexts["I ate a lot of chips and it was amazing!"]
        let pastText = app.staticTexts["Watched a beautiful sunset"]
        let yesterday = try XCTUnwrap(Calendar.current.date(byAdding: .day, value: -1, to: today))

        selectDay(yesterday)
        XCTAssertTrue(yesterdayText.waitForExistence(timeout: 2.0), "Yesterday's record is missing")
        XCTAssertFalse(pastText.exists, "A record of another day is shown")

        selectDay(past32Date)
        XCTAssertTrue(pastText.waitForExistence(timeout: 2.0), "The record of the newly selected day is missing")
        XCTAssertFalse(yesterdayText.exists, "The previous day's record is still shown after switching days")

        selectDay(yesterday)
        XCTAssertTrue(yesterdayText.waitForExistence(timeout: 2.0), "Yesterday's record did not come back")
        XCTAssertFalse(pastText.exists, "The other day's record is still shown after switching back")
    }

    // Check empty date
    func test_EmptyDayShowsNoRecords() throws {
        app.buttons["HeaderToggleButton"].tap()
                

        let emptyDayCell = app.buttons["DayCell_\(dateKey(for: today))"]
        
        XCTAssertTrue(emptyDayCell.waitForExistence(timeout: 2.0), "Today's cell should exist on the screen")
        
        emptyDayCell.tap()
        
        XCTAssertTrue(app.staticTexts["No records for this day"].exists)
    }

    // Check future day
    func test_FutureDayShowsNotStartedYet() throws {
        app.buttons["HeaderToggleButton"].tap()
        
        let futureDayCell = app.buttons["DayCell_\(dateKey(for: future1Date))"]
                
        if futureDayCell.waitForExistence(timeout: 2.0) {
            futureDayCell.tap()
            XCTAssertTrue(app.staticTexts["Oops! This day has not started yet"].exists)
        }
    }

    // Check the absence of months > current one
    func test_FutureMonthsAreNotAccessible() throws {
        let headerBtn = app.buttons["HeaderToggleButton"]
        headerBtn.tap()
        let currentHeaderStr = headerBtn.label
        
        app.scrollViews.firstMatch.swipeUp()
        
        XCTAssertEqual(headerBtn.label, currentHeaderStr, "Next month is active")
    }
    
    // MARK: - Helpers

    // Opens the calendar (it opens on the month of the selected day), looks for the cell of `date` in the
    // current month, then scrolls toward the present and finally into the past, and taps it
    private func selectDay(_ date: Date) {
        app.buttons["HeaderToggleButton"].tap()
        let cell = app.buttons["DayCell_\(dateKey(for: date))"]
        let calendarScroll = app.scrollViews.firstMatch
        var found = cell.waitForExistence(timeout: 3.0)
        var swipes = 0
        while !found && swipes < 2 {
            calendarScroll.swipeUp()
            found = cell.waitForExistence(timeout: 1.5)
            swipes += 1
        }
        swipes = 0
        while !found && swipes < 6 {
            calendarScroll.swipeDown()
            found = cell.waitForExistence(timeout: 1.5)
            swipes += 1
        }
        XCTAssertTrue(found, "Day cell for \(dateKey(for: date)) was not found")
        cell.tap()
    }

    private func dateKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
