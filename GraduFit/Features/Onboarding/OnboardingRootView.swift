import SwiftUI

/// Milestone 1: visual shell only. No local action can authenticate or complete setup.
struct OnboardingRootView: View {
    @State private var isAccountExpanded = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @ScaledMetric(relativeTo: .title) private var minimumHeaderHeight: CGFloat = 240

    private let progress = OnboardingProgress()

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: -GraduFitTheme.panelRadius) {
                    LandscapeHeader()
                        .frame(height: max(minimumHeaderHeight, min(320, geometry.size.height * 0.37)))

                    VStack(spacing: 24) {
                        VStack(spacing: 8) {
                            Text("Welcome to GraduFit")
                                .font(.title2.weight(.bold))
                                .foregroundStyle(GraduFitTheme.ink)
                                .accessibilityAddTraits(.isHeader)
                            Text("Let’s get your account set up so we can personalize your experience.")
                                .font(.subheadline)
                                .foregroundStyle(GraduFitTheme.secondaryText)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .multilineTextAlignment(.center)

                        VStack(spacing: 10) {
                            OnboardingStepCard(
                                title: "Account Setup", subtitle: "Create your account or sign in",
                                symbol: "person.fill", tint: GraduFitTheme.blue,
                                fill: GraduFitTheme.accountFill, isExpanded: isAccountExpanded,
                                isComplete: progress.accountSetupComplete, isAvailable: true,
                                accessibilityID: "onboarding.account", action: toggleAccount
                            ) {
                                // Replaced by the email/provider form after this screen's review.
                                Text("Account sign-in is not available in this development build.")
                                    .font(.footnote)
                                    .foregroundStyle(GraduFitTheme.secondaryText)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .accessibilityIdentifier("onboarding.developmentNotice")
                            }

                            OnboardingStepCard(
                                title: "Educational Level",
                                subtitle: "Select your current academic or professional level",
                                symbol: "graduationcap.fill", tint: GraduFitTheme.green,
                                fill: GraduFitTheme.educationFill, isExpanded: false,
                                isComplete: progress.educationalLevelComplete, isAvailable: false,
                                accessibilityID: "onboarding.education", action: {}
                            ) { EmptyView() }

                            OnboardingStepCard(
                                title: "User Plan", subtitle: "Choose the plan that fits your goals",
                                symbol: "crown.fill", tint: GraduFitTheme.gold,
                                fill: GraduFitTheme.planFill, isExpanded: false,
                                isComplete: progress.userPlanComplete, isAvailable: false,
                                accessibilityID: "onboarding.plan", action: {}
                            ) { EmptyView() }
                        }

                        PrimaryButton(title: "Continue", isEnabled: false, action: {})
                            .accessibilityIdentifier("onboarding.continue")
                            .accessibilityHint("Complete Account Setup to continue")
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 26)
                    .padding(.bottom, 24)
                    .frame(maxWidth: .infinity)
                    .background(.white, in: UnevenRoundedRectangle(
                        topLeadingRadius: GraduFitTheme.panelRadius,
                        topTrailingRadius: GraduFitTheme.panelRadius
                    ))
                }
                .frame(maxWidth: 560)
                .frame(maxWidth: .infinity)
            }
            .background(Color.white)
            .scrollIndicators(.hidden)
        }
        .preferredColorScheme(.light)
    }

    private func toggleAccount() {
        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.2)) {
            isAccountExpanded.toggle()
        }
    }
}

#Preview("Welcome") {
    OnboardingRootView()
}
