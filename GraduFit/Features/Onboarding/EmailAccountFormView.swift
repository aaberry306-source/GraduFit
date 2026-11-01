import AuthenticationServices
import SwiftUI
import GoogleSignInSwift

/// Email and native provider entry points. Completion remains backend/consent-owned.
struct EmailAccountFormView: View {
    @Binding var form: EmailAccountForm
    @State private var hasSubmitted = false
    @ObservedObject var authentication: AuthenticationCoordinator
    let providerClient: FirebaseAuthenticationClient
    @State private var appleNonce: AppleNonce?
    @State private var isAppleAuthorizing = false
    @State private var providerError: String?
    @FocusState private var focusedField: AccountField?

    private var title: String {
        switch form.mode {
        case .createAccount: "Create Account"
        case .signIn: "Sign In"
        case .resetPassword: "Send Reset Instructions"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            if let account = authentication.account {
                authenticatedStatus(account)
            } else {
            Picker("Account action", selection: modeBinding) {
                Text("Create Account").tag(EmailAccountMode.createAccount)
                Text("Sign In").tag(EmailAccountMode.signIn)
            }
            .pickerStyle(.segmented)
            .accessibilityIdentifier("account.mode")

            if form.mode == .resetPassword {
                Text("Reset your password")
                    .font(.headline)
                    .accessibilityAddTraits(.isHeader)
                Text("Enter your email to request password reset instructions.")
                    .font(.footnote)
                    .foregroundStyle(GraduFitTheme.secondaryText)
            }

            if form.mode == .createAccount {
                field(label: "Name / Nickname", error: error(for: .nickname)) {
                    TextField("Enter your name or nickname", text: $form.nickname)
                        .textContentType(.nickname)
                        .textInputAutocapitalization(.words)
                        .focused($focusedField, equals: .nickname)
                        .submitLabel(.next)
                        .onSubmit { focusedField = .email }
                        .accessibilityIdentifier("account.nickname")
                }
            }

            field(label: "Email Address", error: error(for: .email)) {
                TextField("you@example.com", text: $form.email)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .focused($focusedField, equals: .email)
                    .submitLabel(form.mode == .resetPassword ? .go : .next)
                    .onSubmit {
                        if form.mode == .resetPassword { submit() }
                        else { focusedField = .password }
                    }
                    .accessibilityIdentifier("account.email")
            }

            if form.mode != .resetPassword {
                field(label: "Password", error: error(for: .password)) {
                    SecureField("Enter your password", text: $form.password)
                        .textContentType(form.mode == .createAccount ? .newPassword : .password)
                        .focused($focusedField, equals: .password)
                        .submitLabel(.go)
                        .onSubmit(submit)
                        .accessibilityIdentifier("account.password")
                }
            }

            PrimaryButton(title: title, isEnabled: !authentication.isBusy, action: submit)
                .accessibilityIdentifier("account.submit")

            Button(form.mode == .resetPassword ? "Back to Sign In" : "Forgot password?") {
                setMode(form.mode == .resetPassword ? .signIn : .resetPassword)
            }
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(GraduFitTheme.blue)
            .frame(minHeight: 44)
            .accessibilityIdentifier("account.recovery")

            if form.mode != .resetPassword {
                HStack(spacing: 10) {
                    Rectangle().frame(height: 1)
                    Text("OR").font(.caption)
                    Rectangle().frame(height: 1)
                }
                .foregroundStyle(GraduFitTheme.secondaryText.opacity(0.6))
                .accessibilityHidden(true)

                SignInWithAppleButton(.continue, onRequest: { request in
                    do {
                        let nonce = try AppleNonce()
                        appleNonce = nonce
                        request.requestedScopes = [.fullName, .email]
                        request.nonce = nonce.sha256
                        isAppleAuthorizing = true
                    } catch { providerError = "Secure Apple sign-in could not start. Try again." }
                }, onCompletion: finishApple)
                    .signInWithAppleButtonStyle(.black)
                    .frame(height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .disabled(!authentication.isConfigured || authentication.isBusy)

                GoogleSignInButton {
                    Task {
                        await authentication.authenticateProvider {
                            try await providerClient.signInWithGoogle()
                        }
                    }
                }
                .frame(minHeight: 50)
                .disabled(!authentication.isConfigured || authentication.isBusy)
            }
            } // Signed-out form.

            if authentication.isBusy {
                ProgressView("Contacting authentication…")
                    .accessibilityIdentifier("account.loading")
            }
            if let message = authentication.message {
                Label(message, systemImage: authentication.hasError ? "exclamationmark.circle" : "info.circle")
                    .font(.footnote)
                    .foregroundStyle(authentication.hasError ? Color.red : GraduFitTheme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("account.status")
            }
            if !authentication.isConfigured {
                Text("Connect your Firebase iOS app to enable authentication. See docs/firebase-setup.md in the project. No account has been created.")
                    .font(.footnote)
                    .foregroundStyle(GraduFitTheme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .disabled(authentication.isBusy || isAppleAuthorizing)
        .foregroundStyle(GraduFitTheme.ink)
        .alert("Apple sign-in", isPresented: Binding(
            get: { providerError != nil }, set: { if !$0 { providerError = nil } }
        )) { Button("OK", role: .cancel) { providerError = nil } }
        message: { Text(providerError ?? "") }
        .onDisappear { form.password = "" }
    }

    @ViewBuilder
    private func authenticatedStatus(_ account: AuthenticatedAccount) -> some View {
        Text(account.requiresEmailVerification ? "Verify your email" : "Signed in")
            .font(.headline)
            .accessibilityAddTraits(.isHeader)
        if let email = account.email {
            Text(email).font(.subheadline).textSelection(.enabled)
        }
        if account.displayName == nil {
            Text("Your nickname still needs to be saved during profile setup.")
                .font(.footnote)
        }
        if account.requiresEmailVerification {
            Text("Check your inbox for a verification link. Account Setup remains incomplete until verification and agreement acceptance are confirmed.")
                .font(.footnote)
            PrimaryButton(title: "Check Verification", isEnabled: !authentication.isBusy) {
                Task { await authentication.refreshVerification() }
            }
            Button("Resend verification email") {
                Task { await authentication.resendVerification() }
            }.frame(minHeight: 44)
        } else {
            Text("Identity verified. Agreement and profile persistence are the next implementation checkpoint. Account Setup is not complete yet.")
                .font(.footnote)
        }
        Button("Sign Out") { Task { await authentication.signOut() } }
            .frame(minHeight: 44)
    }

    private func finishApple(_ result: Result<ASAuthorization, Error>) {
        isAppleAuthorizing = false
        let nonce = appleNonce
        appleNonce = nil
        switch result {
        case .success(let authorization):
            guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
                  let nonce else {
                providerError = "Apple sign-in could not be verified. Please try again."
                return
            }
            Task {
                await authentication.authenticateProvider {
                    try await providerClient.signInWithApple(credential, nonce: nonce.raw)
                }
            }
        case .failure(let error):
            if (error as? ASAuthorizationError)?.code != .canceled {
                providerError = "Apple sign-in did not finish. Check Sign in with Apple capability and provider configuration, then retry."
            }
        }
    }

    private var modeBinding: Binding<EmailAccountMode> {
        Binding(get: { form.mode == .resetPassword ? .signIn : form.mode }, set: setMode)
    }

    private func setMode(_ mode: EmailAccountMode) {
        form.changeMode(to: mode)
        hasSubmitted = false
        focusedField = nil
    }

    private func error(for field: AccountField) -> String? {
        hasSubmitted ? form.errors[field] : nil
    }

    private func submit() {
        hasSubmitted = true
        if form.errors[.nickname] != nil { focusedField = .nickname }
        else if form.errors[.email] != nil { focusedField = .email }
        else if form.errors[.password] != nil { focusedField = .password }
        else {
            focusedField = nil
            let submitted = form
            form.password = ""
            hasSubmitted = false
            Task { await authentication.submit(submitted) }
        }
    }

    private func field<Content: View>(label: String, error: String?, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label).font(.subheadline.weight(.semibold))
            content()
                .font(.body)
                .padding(12)
                .background(.white, in: RoundedRectangle(cornerRadius: 8))
                .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(error == nil ? Color.gray.opacity(0.3) : .red))
                .accessibilityLabel(label)
            if let error {
                Label(error, systemImage: "exclamationmark.circle")
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}
