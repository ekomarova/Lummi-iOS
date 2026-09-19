import XCTest

final class SaveFailureUITests: XCTestCase {

    var app: XCUIApplication!

    override func tearDownWithError() throws {
        app = nil
    }

    // `TextField(axis: .vertical)` is reported as a text view on iOS 17 and as a text field
    // on newer versions, so match the edit field by identifier regardless of type.
    private var editRecordField: XCUIElement {
        app.descendants(matching: .any)["EditRecordTextField"].firstMatch
    }

    // MARK: - New Record

    func test_NewRecord_ShowsAlertAndRemainsOpen_OnSaveFailure() throws {
        app = XCUIApplication()
        app.launchArguments = ["-UI_TESTING_SIMULATE_SAVE_FAILURE"]
        app.launch()

        app.buttons["MainRecordButton"].tap()

        let textEditor = app.textViews["RecordInputTextEditor"]
        XCTAssertTrue(textEditor.waitForExistence(timeout: 2.0), "Input sheet did not open")

        textEditor.tap()
        textEditor.typeText("Simulated failure test")

        app.buttons["SaveRecordButton"].tap()

        let alert = app.alerts["Failed to Save"]
        XCTAssertTrue(alert.waitForExistence(timeout: 2.0), "Save failure alert did not appear")
        // Sheet must stay open — dismissing on failure is the bug being fixed
        XCTAssertTrue(textEditor.exists, "Input sheet must remain open after save failure")

        alert.buttons["OK"].tap()

        XCTAssertTrue(textEditor.waitForExistence(timeout: 1.0), "Input sheet should still be open after alert dismissal")
        // Entry must not have leaked into the main view
        XCTAssertFalse(app.staticTexts["Simulated failure test"].exists, "Failed entry should not appear in the records list")
    }

    // MARK: - Delete Record

    func test_DeleteRecord_ShowsAlertAndRecordPersists_OnSaveFailure() throws {
        // Pre-populate via -UI_TESTING_10_RECORDS which calls modelContext.save() directly,
        // bypassing saveOrSimulate(), so records are inserted before the simulation flag takes effect.
        app = XCUIApplication()
        app.launchArguments = ["-UI_TESTING_10_RECORDS", "-UI_TESTING_SIMULATE_SAVE_FAILURE"]
        app.launch()

        let recordToDelete = app.staticTexts["RecordText_0"]
        XCTAssertTrue(recordToDelete.waitForExistence(timeout: 2.0), "Pre-populated records not found")

        recordToDelete.press(forDuration: 1.0)

        let deleteButton = app.buttons["DeleteRecordButton"]
        XCTAssertTrue(deleteButton.waitForExistence(timeout: 2.0), "Delete button did not appear")
        deleteButton.tap()

        let alert = app.alerts["Failed to Delete"]
        XCTAssertTrue(alert.waitForExistence(timeout: 2.0), "Delete failure alert did not appear")

        alert.buttons["OK"].tap()

        // Record should be restored after rollback
        XCTAssertTrue(app.staticTexts["RecordText_0"].waitForExistence(timeout: 2.0), "Record should be restored after failed delete")
    }

    // MARK: - Clear All Data

    func test_ClearAllData_ShowsAlertAndRecordsPersist_OnSaveFailure() throws {
        app = XCUIApplication()
        app.launchArguments = ["-UI_TESTING_10_RECORDS", "-UI_TESTING_SIMULATE_SAVE_FAILURE"]
        app.launch()

        XCTAssertTrue(app.staticTexts["RecordText_0"].waitForExistence(timeout: 2.0), "Pre-populated records not found")

        app.buttons["SettingsButton_Inactive"].tap()

        let clearDataButton = app.buttons["ClearAllDataButton"]
        XCTAssertTrue(clearDataButton.waitForExistence(timeout: 2.0), "Clear All Data button is missing")
        clearDataButton.tap()

        let confirmAlert = app.alerts["Clear All Data?"]
        XCTAssertTrue(confirmAlert.waitForExistence(timeout: 2.0), "Clear Data confirmation did not appear")
        confirmAlert.buttons["Delete"].tap()

        let failureAlert = app.alerts["Failed to Delete"]
        XCTAssertTrue(failureAlert.waitForExistence(timeout: 2.0), "Clear data failure alert did not appear")
        failureAlert.buttons["OK"].tap()

        // Records must be restored after rollback, not silently lost
        let homeButton = app.buttons["HomeButton_Inactive"]
        if homeButton.waitForExistence(timeout: 2.0) {
            homeButton.tap()
        }
        XCTAssertTrue(app.staticTexts["RecordText_0"].waitForExistence(timeout: 3.0), "Records should persist after failed clear")
        XCTAssertFalse(app.staticTexts["No records for this day"].exists, "Empty state must not be shown after failed clear")
    }

    // MARK: - Edit Record

    func test_EditRecord_ShowsAlertAndStaysInEditMode_OnSaveFailure() throws {
        app = XCUIApplication()
        app.launchArguments = ["-UI_TESTING_10_RECORDS", "-UI_TESTING_SIMULATE_SAVE_FAILURE"]
        app.launch()

        let recordToEdit = app.staticTexts["RecordText_0"]
        XCTAssertTrue(recordToEdit.waitForExistence(timeout: 2.0), "Pre-populated records not found")

        recordToEdit.press(forDuration: 1.0)

        let editButton = app.buttons["EditRecordButton"]
        XCTAssertTrue(editButton.waitForExistence(timeout: 2.0), "Edit button did not appear")
        editButton.tap()

        let editField = editRecordField
        XCTAssertTrue(editField.waitForExistence(timeout: 2.0), "Edit field did not appear")

        editField.tap()
        editField.typeText(" updated")

        // Tap the global dismiss area to trigger saveAndDismiss
        app.otherElements["GlobalDismissArea"].firstMatch.tap()

        let alert = app.alerts["Failed to Save"]
        XCTAssertTrue(alert.waitForExistence(timeout: 2.0), "Save failure alert did not appear")
        XCTAssertTrue(editField.exists, "Edit field should remain visible while alert is shown")

        // Tapping OK exits edit mode
        alert.buttons["OK"].tap()
        XCTAssertFalse(editField.waitForExistence(timeout: 2.0), "Edit field should be dismissed after OK")
    }
}
