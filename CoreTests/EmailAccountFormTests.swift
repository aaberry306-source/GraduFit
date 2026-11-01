import XCTest
#if canImport(GraduFitCore)
@testable import GraduFitCore
#else
@testable import GraduFit
#endif

final class EmailAccountFormTests: XCTestCase {
    func testEmptyRegistrationReportsAllRequiredFields() {
        XCTAssertEqual(Set(EmailAccountForm().errors.keys), [.nickname, .email, .password])
    }

    func testSignInDoesNotRequireNickname() {
        var form = EmailAccountForm()
        form.mode = .signIn
        form.email = "learner@example.com"
        form.password = "existing password"
        XCTAssertTrue(form.errors.isEmpty)
    }

    func testRecoveryDoesNotRequirePasswordOrNickname() {
        var form = EmailAccountForm()
        form.mode = .resetPassword
        form.email = "learner@example.com"
        XCTAssertTrue(form.errors.isEmpty)
    }

    func testEmailNormalizationDoesNotModifyPassword() {
        var form = EmailAccountForm()
        form.email = " learner@example.com \n"
        form.password = " password with spaces "
        XCTAssertEqual(form.normalizedEmail, "learner@example.com")
        XCTAssertEqual(form.password, " password with spaces ")
    }

    func testMalformedEmailRejected() {
        for email in ["", "learner", "learner@", "@example.com", "a@@example.com", "a@.com", "a@example.", "a b@example.com"] {
            var form = EmailAccountForm()
            form.email = email
            XCTAssertNotNil(form.errors[.email], email)
        }
    }

    func testModeChangeClearsPasswordAndPreservesNonSensitiveInput() {
        var form = EmailAccountForm()
        form.nickname = "Learner"
        form.email = "learner@example.com"
        form.password = "sensitive"
        form.changeMode(to: .signIn)
        XCTAssertEqual(form.password, "")
        XCTAssertEqual(form.nickname, "Learner")
        XCTAssertEqual(form.email, "learner@example.com")
    }
}
