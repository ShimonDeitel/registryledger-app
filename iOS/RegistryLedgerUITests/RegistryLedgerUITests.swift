import XCTest

final class RegistryLedgerUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func test_addButton_opensAddSheet() throws {
        let app = XCUIApplication()
        app.launch()
        app.buttons["addButton"].tap()
        XCTAssertTrue(app.buttons["saveEntryButton"].waitForExistence(timeout: 2))
        app.buttons["cancelEntryButton"].tap()
    }

    func test_freeLimitTriggersPaywall() throws {
        let app = XCUIApplication()
        app.launch()
        for _ in 0..<40 {
            if app.buttons["subscribeButton"].waitForExistence(timeout: 1) {
                break
            }
            app.buttons["addButton"].tap()
            if app.buttons["saveEntryButton"].waitForExistence(timeout: 1) {
                app.buttons["saveEntryButton"].tap()
            }
        }
        XCTAssertTrue(app.buttons["subscribeButton"].exists || app.buttons["paywallDismissButton"].exists)
    }

    func test_keyboardDismissesOnTapOutside() throws {
        let app = XCUIApplication()
        app.launch()
        app.buttons["addButton"].tap()
        let textField = app.textFields.firstMatch
        if textField.waitForExistence(timeout: 2) {
            textField.tap()
            app.staticTexts["New Gift"].tap()
            XCTAssertFalse(app.keyboards.element.exists)
        }
        app.buttons["cancelEntryButton"].tap()
    }

    func test_settingsButton_opensSettings() throws {
        let app = XCUIApplication()
        app.launch()
        app.buttons["settingsButton"].tap()
        XCTAssertTrue(app.buttons["settingsDoneButton"].waitForExistence(timeout: 2))
        app.buttons["settingsDoneButton"].tap()
    }
}
