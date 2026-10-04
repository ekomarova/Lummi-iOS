import XCTest

final class StorageErrorUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    private func launchApp(with arguments: [String]) {
        app.launchArguments = arguments
        app.launch()
    }

    private var errorTitle: XCUIElement { app.staticTexts["StorageErrorTitle"] }
    private var retryButton: XCUIElement { app.buttons["StorageErrorRetryButton"] }
    private var recordButton: XCUIElement { app.buttons["MainRecordButton"] }

    private func waitForDisappearance(of element: XCUIElement, timeout: TimeInterval = 5.0) {
        let expectation = expectation(for: NSPredicate(format: "exists == false"), evaluatedWith: element, handler: nil)
        wait(for: [expectation], timeout: timeout)
    }

    // MARK: - No store can be opened

    func test_StorageError_ShowsErrorScreenInsteadOfApp() throws {
        launchApp(with: ["-UI_TESTING_FORCE_STORE_ERROR"])

        XCTAssertTrue(errorTitle.waitForExistence(timeout: 5.0), "Storage error screen did not appear")
        XCTAssertTrue(retryButton.exists, "Try Again button is missing")
        XCTAssertTrue(app.staticTexts["StorageErrorDetails"].exists, "Technical error details are missing")

        // The user must not be able to add joys to the throwaway store.
        XCTAssertFalse(recordButton.exists, "App content must not be reachable while the store is unavailable")
        XCTAssertFalse(app.buttons["SettingsButton_Inactive"].exists, "Toolbar must not be reachable while the store is unavailable")
    }

    func test_StorageError_ScreenStaysAfterRetry_WhenStoreStillFails() throws {
        launchApp(with: ["-UI_TESTING_FORCE_STORE_ERROR"])

        XCTAssertTrue(retryButton.waitForExistence(timeout: 5.0))
        retryButton.tap()

        XCTAssertTrue(errorTitle.waitForExistence(timeout: 2.0), "Error screen should remain when the retry fails too")
        XCTAssertFalse(recordButton.exists, "App content must stay hidden when the retry fails")
    }

    func test_StorageError_RetryOpensApp_WhenStoreRecovers() throws {
        launchApp(with: ["-UI_TESTING_FORCE_STORE_ERROR_ONCE"])

        XCTAssertTrue(retryButton.waitForExistence(timeout: 5.0), "Storage error screen did not appear")
        retryButton.tap()

        XCTAssertTrue(recordButton.waitForExistence(timeout: 5.0), "App did not open after the store recovered")
        waitForDisappearance(of: errorTitle)
    }

    // MARK: - iCloud store fails, local store opens

    func test_LaunchFallback_ShowsSyncAlertAndOpensApp_WhenICloudStoreFails() throws {
        launchApp(with: ["-UI_TESTING_SYNC_ENABLED_AT_LAUNCH", "-UI_TESTING_FORCE_SYNC_ERROR"])

        let alert = app.alerts["iCloud Sync Error"]
        XCTAssertTrue(alert.waitForExistence(timeout: 5.0), "Sync error alert should appear after the launch fallback")
        XCTAssertFalse(errorTitle.exists, "The local store opened, so the full-screen error must not appear")

        alert.buttons["OK"].tap()
        waitForDisappearance(of: alert)

        XCTAssertTrue(recordButton.waitForExistence(timeout: 2.0), "App content should be available on the local store")
    }

    func test_LaunchFallback_TurnsICloudToggleOff() throws {
        launchApp(with: ["-UI_TESTING_SYNC_ENABLED_AT_LAUNCH", "-UI_TESTING_FORCE_SYNC_ERROR"])

        let alert = app.alerts["iCloud Sync Error"]
        XCTAssertTrue(alert.waitForExistence(timeout: 5.0))
        alert.buttons["OK"].tap()

        app.buttons["SettingsButton_Inactive"].tap()
        let syncToggle = app.switches["iCloudSyncToggle"]
        XCTAssertTrue(syncToggle.waitForExistence(timeout: 5.0))
        XCTAssertEqual(syncToggle.value as? String, "0", "The switch must show iCloud as off, matching the local store that opened")
    }
}
