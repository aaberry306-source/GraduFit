# Account Setup implementation checkpoints

Approved direction: SwiftUI, iOS 17+, Firebase Authentication + Firestore, native AuthenticationServices and official Google Sign-In, explicit secure account linking, required email ownership verification for manual registration, server-authoritative agreement and completion. Only Account Setup is in scope.

1. Project, domain routing model/tests, welcome visual shell. Product owner built/ran the shell and supplied Simulator screenshots; unit/UI test execution remains unreported.
2. **Current:** email registration/sign-in/recovery form, local validation tests, provisional app icon, and screenshot-based welcome adjustments. Valid submissions explicitly report missing service setup; no simulated identity is created. Await macOS build/run/visual review of this increment. Live coordinator and loading/retry tests follow with backend integration.
3. Real Firebase email authentication, verification, stable profile resolution, backend rules/integration tests.
4. Native Apple/Google integration, cancellation, restoration, provider collision/linking and revocation handling.
5. GraduFit agreement sheet, legal links, versioning, authenticated server operation recording consent and completion consistently; recoverable failures and relaunch tests.
6. Account sign-out/deletion and accessibility/security/device acceptance tests; typed handoff to the future Educational Level module.

## Required external configuration

- A Mac/Xcode or macOS CI access for every screen's required build/run and screenshot gate.
- Confirm a production bundle identifier, Apple developer team, and signing configuration. The scaffold uses `com.gradufit.GraduFit`, a development identifier that can be changed before integration.
- Firebase project/environment, iOS app registration, email/password + Apple/Google provider configuration, Firestore and backend deployment/billing choices as applicable. Deploy tested access rules before production data.
- Apple Sign in with Apple capability and associated provider configuration; device testing. Provider signing secrets belong on the server/secure provider console.
- Google OAuth client configuration and registered callback URL scheme, configured through the official SDK.
- Email verification/reset delivery, authorized action-link domains and return/deep-link handling.
- Final Terms/Privacy text, HTTPS URLs and version identifiers; no fake legal documents presented as final.
- Original licensed header/logo assets and confirmation of any non-system font.

## Policies still needing precise values

The accepted recommendations establish direction, but final password length/rules, required nickname handling, exact legal text/versions, and the appearance of the minimal account-management entry point need concrete values/design before their respective milestone. These do not block the welcome shell. No nickname gate, password rule, or legal language has been invented in this milestone.

## Completion invariant

An authenticated user is not necessarily onboarded. Show Account Setup complete only after valid identity, applicable email-verification policy, and current affirmative agreement have been verified and persisted by the backend. Future modules remain incomplete until their own requirements are satisfied. No credentials or personal data belong in logs or plain UserDefaults.
