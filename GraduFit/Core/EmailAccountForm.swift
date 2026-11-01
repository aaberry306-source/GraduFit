import Foundation

public enum EmailAccountMode: String, CaseIterable, Sendable {
    case createAccount, signIn, resetPassword
}

public enum AccountField: String, Hashable, Sendable {
    case nickname, email, password
}

public struct EmailAccountForm: Sendable {
    public var mode: EmailAccountMode = .createAccount
    public var nickname = ""
    public var email = ""
    public var password = ""

    public init() {}

    public var normalizedEmail: String {
        email.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    public var errors: [AccountField: String] {
        var result: [AccountField: String] = [:]
        if mode == .createAccount && nickname.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            result[.nickname] = "Enter your name or nickname."
        }
        // Intentionally permissive: the authentication backend is authoritative.
        let parts = normalizedEmail.split(separator: "@", omittingEmptySubsequences: false)
        if parts.count != 2 || parts[0].isEmpty || !parts[1].contains(".") ||
            parts[1].hasPrefix(".") || parts[1].hasSuffix(".") ||
            normalizedEmail.contains(where: { $0.isWhitespace }) {
            result[.email] = "Enter a valid email address."
        }
        if mode != .resetPassword && password.isEmpty {
            result[.password] = "Enter your password."
        }
        return result
    }

    public mutating func changeMode(to newMode: EmailAccountMode) {
        mode = newMode
        password = ""
    }
}
