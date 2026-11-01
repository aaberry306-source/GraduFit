import AuthenticationServices
import SwiftUI

/// This increment provides the real form and local validation. It never fabricates
/// a session: the live authentication adapter must be configured in the next increment.
struct EmailAccountFormView: View {
    @Binding var form: EmailAccountForm
    @State private var hasSubmitted = false
    @State private var showServiceNotice = false
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

            PrimaryButton(title: title, isEnabled: true, action: submit)
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

                SignInWithAppleButton(.continue, onRequest: { _ in }, onCompletion: { _ in })
                    .signInWithAppleButtonStyle(.black)
                    .frame(height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .disabled(true)
                    .accessibilityHint("Unavailable until authentication is configured")

                // Official Google SDK button will replace this disabled layout slot
                // when its OAuth client and verified backend exchange are configured.
                Button("Continue with Google", action: {})
                    .font(.headline)
                    .foregroundStyle(GraduFitTheme.ink)
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(.white, in: RoundedRectangle(cornerRadius: 10))
                    .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(.gray.opacity(0.4)))
                    .disabled(true)
                    .accessibilityHint("Unavailable until authentication is configured")
            }

            Text("Development build: email, Apple, and Google authentication are not connected yet. No account will be created. Agreement acceptance follows verified sign-in.")
                .font(.footnote)
                .foregroundStyle(GraduFitTheme.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .foregroundStyle(GraduFitTheme.ink)
        .alert("Authentication setup required", isPresented: $showServiceNotice) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Firebase and provider configuration have not been connected in this build. Your information has not been sent, no account has been created, and no reset email has been sent.")
        }
        .onDisappear { form.password = "" }
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
            form.password = ""
            showServiceNotice = true
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
