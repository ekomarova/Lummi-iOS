import XCTest

final class SettingsUITests: XCTestCase {

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

    // MARK: - Default tests

    // Check the button color change
    func test_SettingsButtonChangesState() throws {
        launchApp(with: ["-UI_TESTING_CALENDAR"])
        
        let inactiveSettingsBtn = app.buttons["SettingsButton_Inactive"]
        XCTAssertTrue(inactiveSettingsBtn.waitForExistence(timeout: 2.0), "Settings button was not found")
        
        inactiveSettingsBtn.tap()
        
        let activeSettingsBtn = app.buttons["SettingsButton_Active"]
        XCTAssertTrue(activeSettingsBtn.waitForExistence(timeout: 2.0), "Settings button did not become active after pressing")
    }

    // Check Settings header existence
    func test_SettingsTitleExists() throws {
        launchApp(with: ["-UI_TESTING_CALENDAR"])
        app.buttons["SettingsButton_Inactive"].tap()
        
        let title = app.staticTexts["Settings".uppercased()]
        XCTAssertTrue(title.waitForExistence(timeout: 2.0), "Settings header did not appear on the screen.")
    }

    // MARK: - Theme tests

    // Check Appearance section and options
    func test_AppearanceSectionExists() throws {
        launchApp(with: ["-UI_TESTING_CALENDAR"])
        app.buttons["SettingsButton_Inactive"].tap()
        
        let appearanceLabel = app.staticTexts["Appearance".uppercased()]
        XCTAssertTrue(appearanceLabel.waitForExistence(timeout: 2.0), "Appearance label is missing")
        
        let lightBtn = app.buttons["LightThemeButton"]
        let darkBtn = app.buttons["DarkThemeButton"]
        
        XCTAssertTrue(lightBtn.exists, "Light theme option is missing")
        XCTAssertTrue(darkBtn.exists, "Dark theme option is missing")
    }

    // Check theme change
    func test_ThemeSelectionSwitchesState() throws {
        launchApp(with: ["-UI_TESTING_CALENDAR"])
        app.buttons["SettingsButton_Inactive"].tap()
        
        let lightBtn = app.buttons["LightThemeButton"]
        let darkBtn = app.buttons["DarkThemeButton"]
        XCTAssertTrue(lightBtn.waitForExistence(timeout: 2.0))

        lightBtn.tap()

        XCTAssertEqual(lightBtn.value as? String, "Selected", "Light theme is not active")
        XCTAssertEqual(darkBtn.value as? String, "Unselected", "Dark theme is active")
        
        darkBtn.tap()

        XCTAssertEqual(darkBtn.value as? String, "Selected", "Dark theme is not active")
        XCTAssertEqual(lightBtn.value as? String, "Unselected", "Light theme is active")
    }
    
    // MARK: - Language tests
        
    // Check language button
    func test_LanguageSectionExists() throws {
        launchApp(with: ["-UI_TESTING_CALENDAR"])
        app.buttons["SettingsButton_Inactive"].tap()
        
        let languageLabel = app.staticTexts["LanguageLabel"]
        XCTAssertTrue(languageLabel.waitForExistence(timeout: 2.0), "Language label is missing")

        let languagePicker = app.buttons["LanguagePicker"]
        XCTAssertTrue(languagePicker.exists, "Language picker is missing")
    }
    
    // Check language changing
    func test_LanguageSelectionChangesAppLanguage() throws {
        launchApp(with: ["-UI_TESTING_CALENDAR"])
        app.buttons["SettingsButton_Inactive"].tap()
        
        let languageLabel = app.staticTexts["LanguageLabel"]
        let languagePicker = app.buttons["LanguagePicker"]

        XCTAssertTrue(languageLabel.waitForExistence(timeout: 2.0))
        XCTAssertTrue(languagePicker.waitForExistence(timeout: 2.0))

        languagePicker.tap()
        app.buttons["Русский"].tap()

        XCTAssertEqual(languageLabel.label.uppercased(), "Язык".uppercased(), "The language has not switched to Russian")

        languagePicker.tap()
        app.buttons["Deutsch"].tap()
        
        XCTAssertEqual(languageLabel.label.uppercased(), "Sprache".uppercased(), "The language has not switched to German")

        languagePicker.tap()
        app.buttons["English"].tap()
        
        XCTAssertEqual(languageLabel.label.uppercased(), "Language".uppercased(), "The language has not switched to English")
    }
    
    // MARK: - iCloud Sync tests
        
    // Check iCloud Sync section and options
    func test_iCloudSyncSectionExists() throws {
        launchApp(with: ["-UI_TESTING_CALENDAR"])
        app.buttons["SettingsButton_Inactive"].tap()
        
        let iCloudLabel = app.staticTexts["ICLOUD SYNC"]
        XCTAssertTrue(iCloudLabel.waitForExistence(timeout: 2.0), "iCloud Sync label is missing")
        
        let disabledBtn = app.buttons["iCloudDisabledButton"]
        let enabledBtn = app.buttons["iCloudEnabledButton"]
        
        XCTAssertTrue(disabledBtn.exists, "iCloud disabled button is missing")
        XCTAssertTrue(enabledBtn.exists, "iCloud enabled button is missing")
    }

    // Check iCloud sync state change
    func test_iCloudSyncSelectionSwitchesState() throws {
        launchApp(with: ["-UI_TESTING_CALENDAR"])
        app.buttons["SettingsButton_Inactive"].tap()
        
        let disabledBtn = app.buttons["iCloudDisabledButton"]
        let enabledBtn = app.buttons["iCloudEnabledButton"]
        XCTAssertTrue(disabledBtn.waitForExistence(timeout: 2.0))
        
        enabledBtn.tap()

        XCTAssertEqual(enabledBtn.value as? String, "Selected", "iCloud Sync did not become enabled")
        XCTAssertEqual(disabledBtn.value as? String, "Unselected", "iCloud disabled button is still active")

        disabledBtn.tap()

        XCTAssertEqual(disabledBtn.value as? String, "Selected", "iCloud Sync did not become disabled")
        XCTAssertEqual(enabledBtn.value as? String, "Unselected", "iCloud enabled button is still active")
    }
    
    func test_iCloudSyncErrorOverlayAppearsAndReverts() throws {
        launchApp(with: ["-UI_TESTING_FORCE_SYNC_ERROR"])

        app.buttons["SettingsButton_Inactive"].tap()

        let disabledBtn = app.buttons["iCloudDisabledButton"]
        let enabledBtn = app.buttons["iCloudEnabledButton"]
        XCTAssertTrue(disabledBtn.waitForExistence(timeout: 5.0))
        XCTAssertTrue(enabledBtn.waitForExistence(timeout: 5.0))

        // Verify initial state: sync is off
        XCTAssertEqual(disabledBtn.value as? String, "Selected", "iCloud sync should be off by default")
        XCTAssertEqual(enabledBtn.value as? String, "Unselected")

        // Try to enable sync — should fail and trigger the error overlay
        enabledBtn.tap()

        let alertTitle = app.staticTexts["SyncErrorAlertTitle"]
        XCTAssertTrue(alertTitle.waitForExistence(timeout: 5.0), "Sync error overlay should appear after container failure")

        // Toggle must have reverted back to disabled
        XCTAssertEqual(disabledBtn.value as? String, "Selected", "iCloud toggle should revert to disabled after error")
        XCTAssertEqual(enabledBtn.value as? String, "Unselected", "iCloud enabled button should be unselected after error")

        // Dismiss the overlay
        app.buttons["SyncErrorAlertOKButton"].tap()

        let doesNotExistPredicate = NSPredicate(format: "exists == false")
        let dismissExpectation = expectation(for: doesNotExistPredicate, evaluatedWith: alertTitle, handler: nil)
        wait(for: [dismissExpectation], timeout: 5.0)
    }

    // CI/UI-testing builds have no iCloud entitlement (see CloudKitSyncMonitor), so this
    // covers the generic "sync unavailable" banner without depending on real account state.
    func test_iCloudSyncErrorBannerDisplays() throws {
        launchApp(with: ["-UI_TESTING_CALENDAR"])

        // Navigate to settings
        app.buttons["SettingsButton_Inactive"].tap()

        // The banner should NOT be visible initially because Sync is off by default
        let bannerMessage = app.staticTexts["SyncBannerMessage"]
        XCTAssertFalse(bannerMessage.exists, "Banner should not be visible when iCloud Sync is disabled")

        // Enable Sync
        let enableSyncBtn = app.buttons["iCloudEnabledButton"]
        XCTAssertTrue(enableSyncBtn.waitForExistence(timeout: 5.0))
        enableSyncBtn.tap()

        XCTAssertTrue(bannerMessage.waitForExistence(timeout: 5.0), "Banner should be visible when iCloud Sync is enabled but unavailable")
    }

    // Exercises the real production copy for the "logged out of iCloud" state, which
    // -UI_TESTING_ICLOUD_LOGGED_OUT reports deterministically since live account status
    // isn't available in signed-less test builds.
    func test_iCloudSyncErrorBannerDisplays_WhenLoggedOut() throws {
        launchApp(with: ["-UI_TESTING_CALENDAR", "-UI_TESTING_ICLOUD_LOGGED_OUT"])

        app.buttons["SettingsButton_Inactive"].tap()
        let enableSyncBtn = app.buttons["iCloudEnabledButton"]
        XCTAssertTrue(enableSyncBtn.waitForExistence(timeout: 5.0))
        enableSyncBtn.tap()

        let bannerMessage = app.staticTexts["Synchronization is suspended. Please log in to iCloud in Settings."]
        XCTAssertTrue(bannerMessage.waitForExistence(timeout: 5.0), "Banner should show the logged-out message when iCloud account is signed out")
    }

    // MARK: - Clear Data tests
    
    func test_ClearAllDataSectionExistsAndDeletes() throws {
        launchApp(with: ["-UI_TESTING_CALENDAR"])
        app.buttons["SettingsButton_Inactive"].tap()
        
        let clearDataBtn = app.buttons["ClearAllDataButton"]
        XCTAssertTrue(clearDataBtn.waitForExistence(timeout: 2.0), "Clear All Data button is missing")
        
        clearDataBtn.tap()
        
        let alertTitle = app.staticTexts["ClearDataAlertTitle"]
        XCTAssertTrue(alertTitle.waitForExistence(timeout: 2.0), "Clear Data alert should appear")
        
        let cancelButton = app.buttons["ClearDataCancelButton"]
        let confirmButton = app.buttons["ClearDataConfirmButton"]
        
        XCTAssertTrue(cancelButton.exists, "Cancel button is missing")
        XCTAssertTrue(confirmButton.exists, "Confirm button is missing")
        
        // Cancel first
        cancelButton.tap()
        
        // Wait for the alert to completely disappear
        let doesNotExistPredicate = NSPredicate(format: "exists == false")
        let cancelExpectation = expectation(for: doesNotExistPredicate, evaluatedWith: alertTitle, handler: nil)
        wait(for: [cancelExpectation], timeout: 2.0)
        
        // Tap again and confirm
        clearDataBtn.tap()
        XCTAssertTrue(alertTitle.waitForExistence(timeout: 2.0), "Clear Data alert should appear on second tap")
        
        confirmButton.tap()
        
        let confirmExpectation = expectation(for: doesNotExistPredicate, evaluatedWith: alertTitle, handler: nil)
        wait(for: [confirmExpectation], timeout: 2.0)
    }

    func test_ClearAllDataActuallyRemovesRecords() throws {
        // Launch with 10 records for the CURRENT day so they show up on the main screen immediately
        launchApp(with: ["-UI_TESTING_10_RECORDS"])
        
        // Go to Settings
        app.buttons["SettingsButton_Inactive"].tap()

        // Trigger data deletion
        let clearDataBtn = app.buttons["ClearAllDataButton"]
        XCTAssertTrue(clearDataBtn.waitForExistence(timeout: 2.0))
        clearDataBtn.tap()

        let alertTitle = app.staticTexts["ClearDataAlertTitle"]
        XCTAssertTrue(alertTitle.waitForExistence(timeout: 2.0))
        app.buttons["ClearDataConfirmButton"].tap()
        
        // Wait for dismissal
        let doesNotExistPredicate = NSPredicate(format: "exists == false")
        let confirmExpectation = expectation(for: doesNotExistPredicate, evaluatedWith: alertTitle, handler: nil)
        wait(for: [confirmExpectation], timeout: 2.0)
        
        // Navigate back to the Home Screen
        let homeBtn = app.buttons["HomeButton_Inactive"]
        if homeBtn.waitForExistence(timeout: 2.0) {
            homeBtn.tap()
        }
        
        // Verify the empty state is shown
        let noRecordsLabel = app.staticTexts["NO RECORDS FOR THIS DAY"]
        XCTAssertTrue(noRecordsLabel.waitForExistence(timeout: 3.0), "Expected 'NO RECORDS FOR THIS DAY' to appear, meaning data was successfully deleted.")
    }
}
