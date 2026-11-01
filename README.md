# GraduFit

Native SwiftUI application combining academic studying and exercise. Current milestone: **welcome interface, account-entry form, and app icon**. Live authentication is not connected yet.

## Open and run

- Use a Mac with Xcode 16 or newer and an installed iOS Simulator runtime. Deployment target: iOS 17; iPhone, portrait. No external packages are needed for this milestone.
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
- A valid submission explains that authentication setup is required; no account or reset email is fabricated. Provider controls are disabled until native SDK/backend integration is configured.
- A generated provisional GraduFit icon is connected through the AppIcon asset catalog. Original landscape/logo artwork is still needed for exact visual fidelity.
- Continue remains disabled. Future modules are visible, disabled placeholders with accessibility explanations.
- Scrollable layout, Dynamic Type, VoiceOver labels, and Reduce Motion handling.
- There is no session/profile persistence yet. The launch state is deliberately incomplete.

## Structure

`App` contains the application entry point; `Core` contains platform-independent progress/routing; `DesignSystem` contains reusable visuals; `Features/Onboarding` owns the welcome interface. Dependencies for authentication, profiles, and consent will be added in later reviewed increments. Future module UI is not implemented.

The same domain test source runs through Swift Package Manager or the Xcode unit-test target. UI tests exercise the welcome screen and retain screenshots; screenshots require human/reference review and are not automatically pixel-compared.

## External setup for subsequent milestones

See `docs/account-setup-plan.md`. Firebase, Apple, and Google authentication are **not integrated** in this milestone. Do not mistake the visual shell for a functional account system. Never commit credentials, service-account keys, session tokens, or production personal information. Supply SDK configuration through local/build configuration when integration begins; client configuration is distinct from server secrets.

## Validation status

This environment runs Linux without Swift/Xcode. Offline project integrity checks pass. The product owner successfully built/ran the previous welcome-shell commit in Simulator and supplied screenshots; test execution was not reported. The current account-form/icon changes still require compilation, XCTest execution, Simulator launch, and screenshot comparison on macOS. No App Store readiness is claimed.
