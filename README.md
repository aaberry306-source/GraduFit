# GraduFit

Native SwiftUI application combining academic studying and exercise. Current milestone: **welcome interface, account-entry form, and app icon**. Live Firebase/email and Apple/Google SDK adapters are implemented; your Firebase/provider configuration is required to activate and test them. Profile/consent persistence is still pending.

## Open and run

- Use a Mac with Xcode 16.2 or newer and an installed iOS Simulator runtime. Deployment target: iOS 17; iPhone, portrait. Xcode resolves Firebase 12.x and Google Sign-In 9.x through Swift Package Manager.
- Open `GraduFit.xcodeproj`, choose the **GraduFit** scheme, select an iPhone Simulator, and Run.
- Simulator builds do not require an Apple developer account. Device builds require selecting your signing team and an available bundle identifier in Xcode.
- Run tests with Product → Test, or use the commands below. No service credentials are required to display this screen.

```bash
python3 scripts/validate_project.py
xcrun simctl list devices available
GRADUFIT_SIMULATOR_ID=<iPhone-UDID> bash scripts/validate_ios.sh
```

The script builds, tests, installs, and launches the app. Open the generated `.xcresult` in Xcode to inspect test outcomes and retained screenshots. Review the UI against the supplied schematics using `docs/visual-review.md` before the next screen is implemented.

The domain routing tests can also run independently on any machine with Swift 5.9+:

```bash
swift test
```

## Current behavior

- Landscape branding, welcome text, blue Account Setup, green Educational Level, and peach User Plan cards.
- Account Setup expands into Create Account / Sign In with nickname, email, secure password input, inline errors, and password-reset request mode.
- Local validation checks required fields and basic email structure. Password strength and email ownership must be enforced by the real backend when integrated; this form does not claim a password satisfies a configured policy.
- Email create/sign-in/reset, verification/reload, session restoration and sign-out use Firebase. Apple uses AuthenticationServices with a secure nonce; Google uses its official SDK and callback handling. Missing configuration produces a safe setup message; no account or reset email is fabricated.
- A generated provisional GraduFit icon is connected through the AppIcon asset catalog. Original landscape/logo artwork is still needed for exact visual fidelity.
- Continue remains disabled. Future modules are visible, disabled placeholders with accessibility explanations.
- Scrollable layout, Dynamic Type, VoiceOver labels, and Reduce Motion handling.
- Firebase SDK securely manages the authenticated session. Firestore profiles and legal-consent/completion persistence are not yet implemented, so Account Setup remains incomplete even after identity verification.

## Structure

`App` contains the application entry point; `Core` contains platform-independent progress/routing; `DesignSystem` contains reusable visuals; `Features/Onboarding` owns the welcome interface. The Authentication folder contains injectable orchestration and a live Firebase client. Profile and consent services will follow in later reviewed increments. Future module UI is not implemented.

The same domain test source runs through Swift Package Manager or the Xcode unit-test target. UI tests exercise the welcome screen and retain screenshots; screenshots require human/reference review and are not automatically pixel-compared.

## External setup for subsequent milestones

Follow **[docs/firebase-setup.md](docs/firebase-setup.md)** to create your Firebase project, add its iOS configuration, enable providers, and configure callbacks/capabilities. SDK integration code is present; it has not yet been compiled or validated against live providers in this environment. Do not mistake the visual shell for a functional account system. Never commit credentials, service-account keys, session tokens, or production personal information. Supply SDK configuration through local/build configuration when integration begins; client configuration is distinct from server secrets.

## Validation status

This environment runs Linux without Swift/Xcode. Offline project integrity checks pass. The product owner successfully built/ran the previous welcome-shell commit in Simulator and supplied screenshots; test execution was not reported. The current authentication integration still requires compilation, XCTest execution, Simulator launch, and screenshot comparison on macOS. No App Store readiness is claimed.
