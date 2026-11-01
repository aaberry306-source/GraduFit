import XCTest

final class WelcomeScreenTests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--ui-testing-no-auth"]
        app.launch()
    }

    func testWelcomeCannotSkipAccountSetup() {
        XCTAssertTrue(app.staticTexts["Welcome to GraduFit"].waitForExistence(timeout: 5))
        let button = app.buttons["onboarding.continue"]
        scrollTo(button)
        XCTAssertTrue(button.exists)
        XCTAssertFalse(button.isEnabled)
        XCTAssertFalse(app.buttons["onboarding.education"].isEnabled)
        XCTAssertFalse(app.buttons["onboarding.plan"].isEnabled)
        attachScreenshot("Welcome-collapsed")
    }

    func testAccountAccordionExpandsAndCollapsesWithoutCompleting() {
        let account = app.buttons["onboarding.account"]
        scrollTo(account)
        XCTAssertEqual(account.value as? String, "Collapsed, incomplete")
        account.tap()
        XCTAssertTrue(app.textFields["account.nickname"].waitForExistence(timeout: 3))
        XCTAssertEqual(account.value as? String, "Expanded, incomplete")
        attachScreenshot("Account-form-expanded")
        scrollTo(account)
        account.tap()
        XCTAssertEqual(account.value as? String, "Collapsed, incomplete")
        XCTAssertFalse(app.textFields["account.nickname"].exists)
        scrollTo(app.buttons["onboarding.continue"])
        XCTAssertFalse(app.buttons["onboarding.continue"].isEnabled)
    }

    func testAccessibilityTextSizeKeepsContinueReachable() {
        app.terminate()
        app.launchArguments = ["--ui-testing-no-auth", "-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"]
        app.launch()
        let account = app.buttons["onboarding.account"]
        scrollTo(account)
        XCTAssertTrue(account.isHittable)
        account.tap()
        let button = app.buttons["onboarding.continue"]
        scrollTo(button)
        XCTAssertTrue(button.exists)
        XCTAssertFalse(button.isEnabled)
        attachScreenshot("Welcome-accessibility-XXXL")
    }

    func testInvalidFormStaysIncomplete() {
        let account = app.buttons["onboarding.account"]
        scrollTo(account)
        account.tap()
        let submit = app.buttons["account.submit"]
        scrollTo(submit)
        submit.tap()
        XCTAssertTrue(app.textFields["account.nickname"].exists)
        XCTAssertFalse(app.alerts["Authentication setup required"].exists)
        XCTAssertEqual(account.value as? String, "Expanded, incomplete")
        attachScreenshot("Account-form-validation")
    }

    private func scrollTo(_ element: XCUIElement) {
        for _ in 0..<10 {
            if element.isHittable { return }
            app.swipeUp()
        }
    }

    private func attachScreenshot(_ name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
