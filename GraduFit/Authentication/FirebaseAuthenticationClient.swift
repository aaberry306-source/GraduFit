import AuthenticationServices
import CryptoKit
import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import Security
import UIKit

@MainActor
final class FirebaseAuthenticationClient: EmailAuthenticationClient {
    var isConfigured: Bool { FirebaseApp.app() != nil }
    private var auth: Auth {
        get throws {
            guard isConfigured else {
                throw AuthenticationFailure(message: "Add your Firebase iOS configuration to enable authentication. See docs/firebase-setup.md.")
            }
            return Auth.auth()
        }
    }

    static func configureIfAvailable() {
        #if DEBUG
        // Deterministic UI tests must not restore a real Firebase identity.
        if ProcessInfo.processInfo.arguments.contains("--ui-testing-no-auth") { return }
        #endif
        guard FirebaseApp.app() == nil,
              let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
              let options = FirebaseOptions(contentsOfFile: path) else { return }
        // A mismatched app registration must never authenticate against an unintended app.
        guard options.bundleID == Bundle.main.bundleIdentifier else { return }
        FirebaseApp.configure(options: options)
    }

    func restore() async throws -> AuthenticatedAccount? {
        try await refresh()
    }

    func register(name: String, email: String, password: String) async throws -> AuthenticatedAccount {
        do {
            let result = try await auth.createUser(withEmail: email, password: password)
            // The Firebase identity is already durable. Do not lose it if the
            // optional display-name update fails or ask the user to register twice.
            let change = result.user.createProfileChangeRequest()
            change.displayName = name
            try? await change.commitChanges()
            return account(result.user)
        } catch { throw safe(error) }
    }

    func signIn(email: String, password: String) async throws -> AuthenticatedAccount {
        do { return account(try await auth.signIn(withEmail: email, password: password).user) }
        catch { throw safe(error) }
    }

    func resetPassword(email: String) async throws {
        do { try await auth.sendPasswordReset(withEmail: email) }
        catch {
            // Avoid account enumeration in the recovery confirmation.
            if (error as NSError).code == AuthErrorCode.userNotFound.rawValue { return }
            throw safe(error)
        }
    }

    func refresh() async throws -> AuthenticatedAccount? {
        do {
            guard let user = try auth.currentUser else { return nil }
            try await user.reload()
            _ = try await user.getIDTokenResult(forcingRefresh: true)
            return account(user)
        } catch { throw safe(error) }
    }

    func sendVerification() async throws {
        do {
            guard let user = try auth.currentUser else {
                throw AuthenticationFailure(message: "Sign in before requesting verification.")
            }
            guard !user.isEmailVerified else { return }
            try await user.sendEmailVerification()
        } catch { throw safe(error) }
    }

    func signOut() throws {
        do {
            try auth.signOut()
            GIDSignIn.sharedInstance.signOut()
        } catch { throw safe(error) }
    }

    func signInWithApple(_ credential: ASAuthorizationAppleIDCredential, nonce: String) async throws -> AuthenticatedAccount {
        guard let token = credential.identityToken,
              let tokenString = String(data: token, encoding: .utf8) else {
            throw AuthenticationFailure(message: "Apple did not return a usable credential. Try again.")
        }
        do {
            let verifiedCredential = OAuthProvider.appleCredential(
                withIDToken: tokenString, rawNonce: nonce, fullName: credential.fullName)
            return account(try await auth.signIn(with: verifiedCredential).user)
        } catch { throw safe(error) }
    }

    func signInWithGoogle() async throws -> AuthenticatedAccount {
        guard isConfigured, let clientID = FirebaseApp.app()?.options.clientID else {
            throw AuthenticationFailure(message: "Enable Google in Firebase and download the updated GoogleService-Info.plist.")
        }
        // Validate URL registration before presenting the provider to avoid an SDK exception.
        let requiredScheme = clientID.split(separator: ".").reversed().joined(separator: ".")
        let types = Bundle.main.object(forInfoDictionaryKey: "CFBundleURLTypes") as? [[String: Any]] ?? []
        let schemes = types.flatMap { $0["CFBundleURLSchemes"] as? [String] ?? [] }
        guard schemes.contains(requiredScheme) else {
            throw AuthenticationFailure(message: "Add REVERSED_CLIENT_ID from the Firebase configuration to the app’s URL Schemes. See docs/firebase-setup.md.")
        }
        guard let scene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene }).first(where: { $0.activationState == .foregroundActive }),
              let root = scene.windows.first(where: \.isKeyWindow)?.rootViewController else {
            throw AuthenticationFailure(message: "Sign-in cannot open yet. Please try again.")
        }
        var presenting = root
        while let next = presenting.presentedViewController { presenting = next }
        do {
            GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: presenting)
            guard let token = result.user.idToken?.tokenString else {
                throw AuthenticationFailure(message: "Google did not return a usable credential. Try again.")
            }
            let credential = GoogleAuthProvider.credential(withIDToken: token, accessToken: result.user.accessToken.tokenString)
            return account(try await auth.signIn(with: credential).user)
        } catch {
            // Google documents user cancellation as -5 in GIDSignIn.h.
            // Map the NSError explicitly; it is not a Firebase Auth failure.
            if (error as NSError).domain == kGIDSignInErrorDomain,
               (error as NSError).code == -5 { throw CancellationError() }
            throw safe(error)
        }
    }

    private func account(_ user: User) -> AuthenticatedAccount {
        AuthenticatedAccount(id: user.uid, email: user.email, displayName: user.displayName,
                             requiresEmailVerification: user.providerData.contains { $0.providerID == "password" } && !user.isEmailVerified)
    }

    private func safe(_ error: Error) -> Error {
        if error is AuthenticationFailure { return error }
        switch AuthErrorCode(rawValue: (error as NSError).code) {
        case .emailAlreadyInUse: return AuthenticationFailure(message: "This address cannot be registered. Try Sign In or password recovery.")
        case .weakPassword: return AuthenticationFailure(message: "This password does not meet the account security policy. Choose a stronger password.")
        case .invalidEmail: return AuthenticationFailure(message: "Check the email address and try again.")
        case .wrongPassword, .invalidCredential, .userNotFound: return AuthenticationFailure(message: "Sign-in failed. Check your credentials or use password recovery.")
        case .accountExistsWithDifferentCredential: return AuthenticationFailure(message: "Sign in using your original method. Provider linking requires verifying both accounts; accounts are not merged by email.")
        case .networkError: return AuthenticationFailure(message: "Could not reach authentication. Check your connection and retry.")
        case .tooManyRequests: return AuthenticationFailure(message: "Too many attempts. Please wait before trying again.")
        case .userDisabled: return AuthenticationFailure(message: "This account is unavailable. Contact support.")
        case .operationNotAllowed: return AuthenticationFailure(message: "Enable this sign-in provider in the Firebase Authentication console.")
        default: return AuthenticationFailure(message: "Authentication could not finish. Please try again.")
        }
    }
}

struct AppleNonce {
    let raw: String
    var sha256: String { SHA256.hash(data: Data(raw.utf8)).map { String(format: "%02x", $0) }.joined() }

    init() throws {
        var bytes = [UInt8](repeating: 0, count: 32)
        guard SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes) == errSecSuccess else {
            throw AuthenticationFailure(message: "Secure sign-in could not start. Please try again.")
        }
        raw = bytes.map { String(format: "%02x", $0) }.joined()
    }
}
