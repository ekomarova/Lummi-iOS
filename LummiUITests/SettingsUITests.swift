import XCTest

final class SettingsUITests: XCTestCase {

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

    // MARK: - Default tests

    // Check the button color change
    func test_SettingsButtonChangesState() throws {
        let inactiveSettingsBtn = app.buttons["SettingsButton_Inactive"]
        XCTAssertTrue(inactiveSettingsBtn.waitForExistence(timeout: 2.0), "Settings button was not found")
        
        inactiveSettingsBtn.tap()
        
        let activeSettingsBtn = app.buttons["SettingsButton_Active"]
        XCTAssertTrue(activeSettingsBtn.waitForExistence(timeout: 2.0), "Settings button did not become active after pressing")
    }

    // Check Settings header existence
    func test_SettingsTitleExists() throws {
        app.buttons["SettingsButton_Inactive"].tap()
        
        let title = app.staticTexts["SETTINGS"]
        XCTAssertTrue(title.waitForExistence(timeout: 2.0), "Settings header did not appear on the screen.")
    }

    // MARK: - Theme tests
    // Check Appearance section and options
    func test_AppearanceSectionExists() throws {
        app.buttons["SettingsButton_Inactive"].tap()
        
        let appearanceLabel = app.staticTexts["APPEARANCE"]
        XCTAssertTrue(appearanceLabel.waitForExistence(timeout: 2.0), "Appearance label is missing")
        
        let lightBtn = app.buttons["LightThemeButton"]
        let darkBtn = app.buttons["DarkThemeButton"]
        
        XCTAssertTrue(lightBtn.exists, "Light theme option is missing")
        XCTAssertTrue(darkBtn.exists, "Dark theme option is missing")
    }

    // Check theme change
    func test_ThemeSelectionSwitchesState() throws {
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
}
