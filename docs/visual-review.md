# Milestone 1 — welcome screen review

Source: supplied Complete Account Setup Decision Tree, ONB 01 welcome and completed-card mockups; ONB-DEV 00–03 governs behavior. Use GraduFit everywhere, including the landscape header.

## Review gate

**Pending:** no Mac/Xcode/Simulator is attached. No running-app screenshots or visual-match claims are available. Do not advance to the email/provider or agreement screens until this screen has been built, run, and compared, or the product owner explicitly changes that sequencing requirement.

Run `scripts/validate_ios.sh` on macOS. Inspect the three screenshots retained by UI tests in the `.xcresult`; also inspect the live app at default text size on small and large iPhones. Repeat with accessibility text sizes and VoiceOver. Compare the collapsed screen with the initial ONB 01 screenshot, not the post-completion screenshot.

## Intent preserved in the implementation

- Landscape header above a white panel with rounded upper corners.
- Centered GraduFit title/tagline and welcome message.
- Blue, green, and peach cards in the original order with person, graduation-cap, and crown icons.
- Circular icon backgrounds, subtitles, chevrons, generous rounded corners.
- Grey disabled Continue with trailing arrow; no premature completion checkmark.

## Known differences before Simulator review

| Area | Current implementation / discrepancy | Resolution |
| --- | --- | --- |
| Landscape | Original vector approximation; tree symbols and hills differ from the illustrated screenshot | Obtain original licensed artwork and replace the background asset |
| Logo | SF Symbols running figure plus graduation cap; lacks the exact custom runner/dumbbell mark | Replace with approved vector logo |
| Typography | Dynamic system fonts; source font family/weights are unconfirmed | Compare rendered text and tune with approved font assets if needed |
| Colors/spacing | Centralized approximate values; not pixel sampled or Simulator verified | Tune against equal-size screenshots after first run |
| Disabled Continue | Darker label than the screenshot's white label for legibility | Verify contrast and review this deliberate adjustment |
| Layout | Scrolls on small screens and larger text rather than squeezing content into a fixed image | Verify no clipping, unreachable controls, or header overlap |
| Safe area | Header starts within system safe area; may differ from edge-to-edge artwork in mockup | Inspect real Simulator output before selecting an under-status-bar treatment |
| Expanded card | Development notice only; account form intentionally deferred | Implement in milestone 2 after this gate |
| Future cards | Visible but disabled, with accessible explanation | Enable only when those modules are implemented |

## Record after running

- Xcode / iOS runtime / device: pending.
- Build: not run.
- Unit/UI tests and executed counts: not run.
- Default, expanded, accessibility screenshots: not captured.
- Layout / typography / colors / spacing findings: pending rendered comparison.
- VoiceOver, Reduce Motion, and touch target review: pending.
- Gate: **not passed**.
