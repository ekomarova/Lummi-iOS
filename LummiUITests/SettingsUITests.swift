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
        
        let title = app.staticTexts["Settings"]
        XCTAssertTrue(title.waitForExistence(timeout: 2.0), "Settings header did not appear on the screen.")
    }

    // MARK: - Theme tests

    // Check Appearance section and options
    func test_AppearanceSectionExists() throws {
        launchApp(with: ["-UI_TESTING_CALENDAR"])
        app.buttons["SettingsButton_Inactive"].tap()
        
        let appearanceLabel = app.staticTexts["Appearance"]
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

        let languageSelector = app.buttons["LanguageSelectorButton"]
        XCTAssertTrue(languageSelector.exists, "Language selector is missing")
    }

    // Check language changing
    func test_LanguageSelectionChangesAppLanguage() throws {
        launchApp(with: ["-UI_TESTING_CALENDAR"])
        app.buttons["SettingsButton_Inactive"].tap()

        let languageLabel = app.staticTexts["LanguageLabel"]
        let languageSelector = app.buttons["LanguageSelectorButton"]

        XCTAssertTrue(languageLabel.waitForExistence(timeout: 2.0))
        XCTAssertTrue(languageSelector.waitForExistence(timeout: 2.0))

        languageSelector.tap()
        app.buttons["LanguageOption_ru"].tap()

        XCTAssertTrue(languageSelector.waitForExistence(timeout: 2.0), "Should navigate back to settings after selecting a language")
        XCTAssertEqual(languageLabel.label.uppercased(), "Язык".uppercased(), "The language has not switched to Russian")

        languageSelector.tap()
        app.buttons["LanguageOption_de"].tap()

        XCTAssertEqual(languageLabel.label.uppercased(), "Sprache".uppercased(), "The language has not switched to German")

        languageSelector.tap()
        app.buttons["LanguageOption_en"].tap()

        XCTAssertEqual(languageLabel.label.uppercased(), "Language".uppercased(), "The language has not switched to English")
    }
    
    // MARK: - iCloud Sync tests
        
    // Check iCloud Sync section and options
    func test_iCloudSyncSectionExists() throws {
        launchApp(with: ["-UI_TESTING_CALENDAR"])
        app.buttons["SettingsButton_Inactive"].tap()

        let syncLabel = app.staticTexts["Sync"]
        XCTAssertTrue(syncLabel.waitForExistence(timeout: 2.0), "Sync label is missing")

        let iCloudLabel = app.staticTexts["iCloud"]
        XCTAssertTrue(iCloudLabel.waitForExistence(timeout: 2.0), "iCloud label is missing")

        let syncToggle = app.switches["iCloudSyncToggle"]
        XCTAssertTrue(syncToggle.exists, "iCloud Sync toggle is missing")
    }

    // Check iCloud sync state change
    func test_iCloudSyncSelectionSwitchesState() throws {
        launchApp(with: ["-UI_TESTING_CALENDAR"])
        app.buttons["SettingsButton_Inactive"].tap()

        let syncToggle = app.switches["iCloudSyncToggle"]
        XCTAssertTrue(syncToggle.waitForExistence(timeout: 2.0))

        XCTAssertEqual(syncToggle.value as? String, "0", "iCloud Sync should be off by default")

        syncToggle.tap()

        XCTAssertEqual(syncToggle.value as? String, "1", "iCloud Sync did not become enabled")

        syncToggle.tap()

        XCTAssertEqual(syncToggle.value as? String, "0", "iCloud Sync did not become disabled")
    }

    func test_iCloudSyncErrorOverlayAppearsAndReverts() throws {
        launchApp(with: ["-UI_TESTING_FORCE_SYNC_ERROR"])

        app.buttons["SettingsButton_Inactive"].tap()

        let syncToggle = app.switches["iCloudSyncToggle"]
        XCTAssertTrue(syncToggle.waitForExistence(timeout: 5.0))

        // Verify initial state: sync is off
        XCTAssertEqual(syncToggle.value as? String, "0", "iCloud sync should be off by default")

        // Try to enable sync — should fail and trigger the error overlay
        syncToggle.tap()

        let alertTitle = app.staticTexts["SyncErrorAlertTitle"]
        XCTAssertTrue(alertTitle.waitForExistence(timeout: 5.0), "Sync error overlay should appear after container failure")

        // Toggle must have reverted back to disabled
        XCTAssertEqual(syncToggle.value as? String, "0", "iCloud toggle should revert to disabled after error")

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
        let syncToggle = app.switches["iCloudSyncToggle"]
        XCTAssertTrue(syncToggle.waitForExistence(timeout: 5.0))
        syncToggle.tap()

        XCTAssertTrue(bannerMessage.waitForExistence(timeout: 5.0), "Banner should be visible when iCloud Sync is enabled but unavailable")
    }

    // Exercises the real production copy for the "logged out of iCloud" state, which
    // -UI_TESTING_ICLOUD_LOGGED_OUT reports deterministically since live account status
    // isn't available in signed-less test builds.
    func test_iCloudSyncErrorBannerDisplays_WhenLoggedOut() throws {
        launchApp(with: ["-UI_TESTING_CALENDAR", "-UI_TESTING_ICLOUD_LOGGED_OUT"])

        app.buttons["SettingsButton_Inactive"].tap()
        let syncToggle = app.switches["iCloudSyncToggle"]
        XCTAssertTrue(syncToggle.waitForExistence(timeout: 5.0))
        syncToggle.tap()

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
        let noRecordsLabel = app.staticTexts["No records for this day"]
        XCTAssertTrue(noRecordsLabel.waitForExistence(timeout: 3.0), "Expected 'No records for this day' to appear, meaning data was successfully deleted.")
    }
}
