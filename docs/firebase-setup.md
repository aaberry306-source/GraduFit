# Connect GraduFit authentication

The code uses the real Firebase Authentication SDK, native Sign in with Apple, and official Google Sign-In SDK. No successful mock identity is selected by the app. This integration is not yet compiled or provider-tested in the Linux workspace; build/test on the Mac before relying on it.

## 1. Create the Firebase project

1. Open https://console.firebase.google.com/ and choose **Create a project**.
2. Name it **GraduFit**. Google Analytics is optional and is not required by this app.
3. In Project Overview, choose **Add app → iOS**.
4. Enter the exact bundle identifier **com.gradufit.GraduFit** (matching Xcode). Nickname: GraduFit. The App Store ID can remain empty during development.
5. Register the app and download **GoogleService-Info.plist**.

Use a development Firebase project for initial test users. A separate production environment and release configuration should be established before distribution.

## 2. Put the configuration in Xcode

Use the newest repository ZIP containing the authentication integration, not an earlier project folder.

1. Open its `GraduFit.xcodeproj` on your Mac. Xcode will resolve Firebase and Google Swift packages; allow the first download to finish. Use Xcode 16.2+ (a newer compatible version is fine).
2. In Xcode's left Project navigator, expand the GraduFit project, then drag **GoogleService-Info.plist** from Finder into the GraduFit group.
3. Select **Copy items if needed** (or the equivalent Copy option) and check **GraduFit** target membership. Do not add it to either test target.
4. Select the app target → Build Phases → Copy Bundle Resources. Confirm **GoogleService-Info.plist** appears once.
5. Ensure the actual filename is exactly `GoogleService-Info.plist`, without a `(1)` suffix. If you changed the bundle identifier, register that exact identifier in Firebase and download its configuration.

The app initializes Firebase only when this file is bundled and matches its bundle ID. Without it, the app stays usable as a visual development build and explains the missing setup. The plist is excluded by `.gitignore`; keep your local copy when downloading later updates. Firebase's client plist is app configuration, not an Admin SDK private key. Never put a service-account key or Apple private key in the app.

## 3. Enable email/password first

1. In Firebase Console, open **Build → Authentication → Get started**.
2. Under **Sign-in method**, enable **Email/Password**. Leave email-link/passwordless sign-in off for now.
3. In Authentication settings, configure a password policy; a minimum length of 12 with enforcement is recommended. The app delegates password-strength enforcement to Firebase and reports rejection safely.
4. Review the verification and password-reset email templates, sender settings, authorized action domains, and email-enumeration protection. Do not disable enumeration protection just to expose account-existence details.
5. Run the app in an iPhone Simulator, create a test account, and look under Authentication → Users to confirm the identity exists.
6. Open the verification email's link, return to GraduFit, and tap **Check Verification**. The app reloads the user and refreshes its ID token; it does not trust a local checkbox.

Account creation can succeed while verification email delivery fails. The app keeps the signed-in identity and offers **Resend verification email**, avoiding duplicate registrations. Existing users can Sign In; recovery uses Firebase reset emails and a neutral confirmation. System strong-password suggestions do not establish backend password acceptance or email ownership.

## 4. Enable Google

1. Firebase Authentication → Sign-in method → Google: enable it, select the project support email, and save.
2. Download the updated **GoogleService-Info.plist** from Firebase Project settings → your iOS app, then replace the local Xcode copy (do not add two copies).
3. Find **REVERSED_CLIENT_ID** in that plist on your Mac.
4. In Xcode select the **GraduFit app target → Info → URL Types → +**.
5. Paste REVERSED_CLIENT_ID into **URL Schemes**. Role: Editor. This is the callback registration, not a password.
6. Run again and choose the Google button. The official SDK owns account selection and credentials; the app exchanges its resulting token through Firebase.

The app verifies callback registration before presenting Google, to avoid the SDK crashing on a missing scheme. An invalid/missing provider setup produces a recoverable configuration error. Google user cancellation is handled without marking completion.

## 5. Enable Apple

1. In Firebase Authentication → Sign-in method, enable **Apple** and complete the provider settings requested for your Apple developer configuration. Enter provider secrets only in the secure Firebase/Apple consoles, never in app source or chat.
2. In Xcode → GraduFit app target → Signing & Capabilities, choose your signing team, then **+ Capability → Sign in with Apple**. Xcode creates the entitlement file and associates it with the target; retain those local changes.
3. Confirm the matching App ID in Apple Developer has Sign in with Apple enabled. This capability requires suitable Apple Developer Program access; a free Personal Team does not provide it.
4. Test with an appropriate Apple ID and preferably a physical iPhone. Simulator success alone does not validate all Apple authorization behavior.

If configuring Apple's web/OAuth settings, use the return URL provided by Firebase for your project; do not invent a URL. Native Apple credentials use a cryptographically random nonce and SHA-256 challenge; Firebase validates the credential. Names/emails may be absent after the first authorization or use Apple's private relay. Device passcodes and biometric data remain system-owned.

Email and Google setup can proceed before paid Apple developer access is available. Apple cannot be called ready until the capability, signing, provider settings, and device checks pass.

## 6. Check this milestone

- Build and run the updated app, then run Product → Test (⌘U).
- New email user → Firebase identity → verification required. Verify address → Check Verification → signed-in status.
- Sign out; sign in again; relaunch and verify restoration.
- Request a reset, open the real email, reset, and sign in with the new password.
- Google and Apple → real provider UI → Firebase user; cancel → unchanged account setup. Verify Apple hide-email and repeat authorization on device.
- Test network loss, disabled providers, weak passwords, duplicate requests, and failed verification delivery.
- Backend linking policy must be reviewed/tested before enabling cross-provider linking. The app does not call account-link APIs or merge profiles by matching email.

**Account Setup is intentionally still incomplete after verified sign-in.** Firestore profile resolution, versioned legal consent, server-confirmed completion, secure explicit linking, account deletion, and their acceptance tests remain subsequent implementation checkpoints. No future education/plan module is implemented. Do not distribute this development milestone as a completed account system.
