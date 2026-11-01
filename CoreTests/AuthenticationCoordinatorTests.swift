#if canImport(GraduFit)
import XCTest
@testable import GraduFit

@MainActor
final class AuthenticationCoordinatorTests: XCTestCase {
    func testRegistrationWaitsForVerificationAndDoesNotGrantCompletion() async {
        let client = TestEmailClient()
        let coordinator = AuthenticationCoordinator(client: client)
        await coordinator.submit(validRegistration)
        XCTAssertEqual(coordinator.account?.id, "test-user")
        XCTAssertEqual(coordinator.account?.requiresEmailVerification, true)
        XCTAssertEqual(client.verificationRequests, 1)
        XCTAssertFalse(coordinator.isBusy)
        XCTAssertEqual(OnboardingProgress().nextRequirement, .accountSetup)
    }

    func testVerificationDeliveryFailureRetainsCreatedIdentityForRetry() async {
        let client = TestEmailClient()
        client.failVerification = true
        let coordinator = AuthenticationCoordinator(client: client)
        await coordinator.submit(validRegistration)
        XCTAssertNotNil(coordinator.account)
        XCTAssertTrue(coordinator.hasError)
        client.failVerification = false
        await coordinator.resendVerification()
        XCTAssertFalse(coordinator.hasError)
        XCTAssertEqual(client.registrations, 1)
        XCTAssertEqual(client.verificationRequests, 2)
    }

    func testInvalidSubmissionDoesNotContactBackend() async {
        let client = TestEmailClient()
        let coordinator = AuthenticationCoordinator(client: client)
        await coordinator.submit(EmailAccountForm())
        XCTAssertEqual(client.registrations, 0)
        XCTAssertNil(coordinator.account)
    }

    func testReentrantDoubleSubmissionCreatesOneIdentity() async {
        let client = TestEmailClient()
        let coordinator = AuthenticationCoordinator(client: client)
        let form = validRegistration
        client.onRegister = { await coordinator.submit(form) }
        await coordinator.submit(form)
        XCTAssertEqual(client.registrations, 1)
    }

    func testProviderCancellationDoesNotCreateSessionOrShowFailure() async {
        let coordinator = AuthenticationCoordinator(client: TestEmailClient())
        await coordinator.authenticateProvider { throw CancellationError() }
        XCTAssertNil(coordinator.account)
        XCTAssertFalse(coordinator.hasError)
        XCTAssertFalse(coordinator.isBusy)
    }

    func testRestoreAndSignOut() async {
        let client = TestEmailClient()
        client.restored = client.identity
        let coordinator = AuthenticationCoordinator(client: client)
        await coordinator.restore()
        XCTAssertNotNil(coordinator.account)
        await coordinator.signOut()
        XCTAssertNil(coordinator.account)
    }

    func testResetConfirmationDoesNotCreateSession() async {
        let client = TestEmailClient()
        let coordinator = AuthenticationCoordinator(client: client)
        var form = EmailAccountForm()
        form.mode = .resetPassword
        form.email = "learner@example.com"
        await coordinator.submit(form)
        XCTAssertNil(coordinator.account)
        XCTAssertEqual(client.resetRequests, 1)
        XCTAssertNotNil(coordinator.message)
    }

    private var validRegistration: EmailAccountForm {
        var form = EmailAccountForm()
        form.nickname = "Learner"
        form.email = "learner@example.com"
        form.password = "test-only-password"
        return form
    }
}

/// Test target only; no mock is selected in the app's live dependency graph.
@MainActor
private final class TestEmailClient: EmailAuthenticationClient {
    let isConfigured = true
    let identity = AuthenticatedAccount(id: "test-user", email: "learner@example.com",
                                        displayName: "Learner", requiresEmailVerification: true)
    var restored: AuthenticatedAccount?
    var registrations = 0
    var verificationRequests = 0
    var resetRequests = 0
    var failVerification = false
    var onRegister: (() async -> Void)?

    func restore() async throws -> AuthenticatedAccount? { restored }
    func register(name: String, email: String, password: String) async throws -> AuthenticatedAccount {
        registrations += 1
        await onRegister?()
        return identity
    }
    func signIn(email: String, password: String) async throws -> AuthenticatedAccount { identity }
    func resetPassword(email: String) async throws { resetRequests += 1 }
    func refresh() async throws -> AuthenticatedAccount? { restored }
    func sendVerification() async throws {
        verificationRequests += 1
        if failVerification { throw AuthenticationFailure(message: "Verification email could not be sent.") }
    }
    func signOut() throws { restored = nil }
}
#endif
