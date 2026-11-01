# Milestone 1 — welcome screen review

Source: supplied Complete Account Setup Decision Tree, ONB 01 welcome and completed-card mockups; ONB-DEV 00–03 governs behavior. Use GraduFit everywhere, including the landscape header.

## Review gate

**Welcome built/run by product owner:** supplied Simulator screenshots show the original shell and generic home-screen icon. Comparison identifies an overly simplified landscape/logo, white status-bar strip, muted disabled future cards, and the missing account form. The user requested the icon and account form next. This update adds those assets/controls and adjusts the status-bar background and disabled-card label environment. The account form has not yet been built/run here. Do not advance to the agreement screen before reviewing this increment in Simulator.

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
| Safe area | Previous screenshot showed a white strip; updated background extends sky blue under the status bar | Verify updated Simulator output |
| Expanded card | Added email form, explicit modes/password, local validation, and reset mode; backend unavailable | Verify field layout, keyboard, scrolling and errors; integrate live auth next |
| App icon | Previous screenshot showed generic icon; generated provisional runner/cap/dumbbell artwork is now configured | Rebuild/install and inspect home-screen icon; artwork remains subject to design review |
| Future cards | Visible but disabled, with accessible explanation | Enable only when those modules are implemented |

## Record after running

- Xcode / iOS runtime / device: pending.
- Build: previous welcome-shell build succeeded on user's Mac; current update not run.
- Unit/UI tests and executed counts: not run.
- Default/expanded shell and home-screen screenshots: supplied by user. Current form/accessibility screenshots: not captured.
- Layout / typography / colors / spacing findings: current screenshot confirms simplified hills/logo, white status-bar area, muted future cards; fonts/spacing remain approximate. Current changes need rendered comparison.
- VoiceOver, Reduce Motion, and touch target review: pending.
- Gate: **not passed**.
