import XCTest

final class RecordButtonUITests: XCTestCase {

    var app: XCUIApplication!
    
    let today = Date()

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

        verifyStarOnTodayInCalendar()
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
    
    // Opens the calendar in Insights, checks today's star and returns to Home
    private func verifyStarOnTodayInCalendar() {
        let insightsTab = app.tabItem("Insights", identifier: "InsightsButton")
        insightsTab.tap()

        let todayCell = app.descendants(matching: .any)["DayCell_\(dateKey(for: today))"]
        var swipes = 0
        while !todayCell.waitForExistence(timeout: 1.5) && swipes < 3 {
            app.swipeUp()
            swipes += 1
        }
        XCTAssertTrue(todayCell.exists, "The calendar is missing in Insights")

        XCTAssertEqual(todayCell.value as? String, "Filled", "The star has not appeared today.")

        app.tabItem("Home", identifier: "HomeButton").tap()
    }

    private func dateKey(for date: Date) -> String {
        date.uiTestDateKey
    }
}
