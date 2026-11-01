import Foundation
import Combine

struct AuthenticatedAccount: Equatable {
    let id: String
    let email: String?
    let displayName: String?
    let requiresEmailVerification: Bool
}

@MainActor
protocol EmailAuthenticationClient {
    var isConfigured: Bool { get }
    func restore() async throws -> AuthenticatedAccount?
    func register(name: String, email: String, password: String) async throws -> AuthenticatedAccount
    func signIn(email: String, password: String) async throws -> AuthenticatedAccount
    func resetPassword(email: String) async throws
    func refresh() async throws -> AuthenticatedAccount?
    func sendVerification() async throws
    func signOut() throws
}

/// Identity and UI state only. Neither a successful SDK result nor a local flag
/// grants agreement acceptance or Account Setup completion.
@MainActor
final class AuthenticationCoordinator: ObservableObject {
    @Published private(set) var account: AuthenticatedAccount?
    @Published private(set) var isBusy = false
    @Published private(set) var message: String?
    @Published private(set) var hasError = false
    private let client: any EmailAuthenticationClient

    init(client: any EmailAuthenticationClient) { self.client = client }
    var isConfigured: Bool { client.isConfigured }

    func restore() async {
        guard isConfigured else { return }
        await perform {
            self.account = try await self.client.restore()
        }
    }

    func submit(_ form: EmailAccountForm) async {
        guard form.errors.isEmpty else { return }
        await perform {
            switch form.mode {
            case .createAccount:
                // Retry after email-delivery failure through verification controls,
                // never by registering the same identity again.
                self.account = try await self.client.register(
                    name: form.nickname.trimmingCharacters(in: .whitespacesAndNewlines),
                    email: form.normalizedEmail, password: form.password)
                try await self.client.sendVerification()
                self.message = "Account created. Check your email to verify your address, then tap Check Verification."
            case .signIn:
                self.account = try await self.client.signIn(email: form.normalizedEmail, password: form.password)
            case .resetPassword:
                try await self.client.resetPassword(email: form.normalizedEmail)
                self.message = "If an account can receive reset instructions, an email will arrive shortly."
            }
        }
    }

    func refreshVerification() async {
        await perform { self.account = try await self.client.refresh() }
    }

    func resendVerification() async {
        await perform {
            try await self.client.sendVerification()
            self.message = "Verification email sent. Check your inbox and spam folder."
        }
    }

    func signOut() async {
        await perform {
            try self.client.signOut()
            self.account = nil
        }
    }

    func authenticateProvider(_ operation: @escaping @MainActor () async throws -> AuthenticatedAccount) async {
        await perform { self.account = try await operation() }
    }

    private func perform(_ operation: @MainActor () async throws -> Void) async {
        guard !isBusy else { return }
        isBusy = true
        message = nil
        hasError = false
        defer { isBusy = false }
        do { try await operation() }
        catch is CancellationError { /* Provider cancellation is not a login failure. */ }
        catch {
            hasError = true
            // Only service-owned safe messages reach the UI; never expose raw SDK errors.
            message = (error as? AuthenticationFailure)?.message ?? "Sign-in could not finish. Check your connection and try again."
        }
    }
}

struct AuthenticationFailure: Error {
    let message: String
}
