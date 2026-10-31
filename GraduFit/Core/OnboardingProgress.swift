/// Backend-confirmed facts only. UI selections must never grant completion.
public struct OnboardingProgress: Equatable, Sendable {
    public let accountSetupComplete: Bool
    public let educationalLevelComplete: Bool
    public let userPlanComplete: Bool

    public init(
        accountSetupComplete: Bool = false,
        educationalLevelComplete: Bool = false,
        userPlanComplete: Bool = false
    ) {
        self.accountSetupComplete = accountSetupComplete
        self.educationalLevelComplete = educationalLevelComplete
        self.userPlanComplete = userPlanComplete
    }

    public var nextRequirement: OnboardingRequirement? {
        if !accountSetupComplete { return .accountSetup }
        if !educationalLevelComplete { return .educationalLevel }
        if !userPlanComplete { return .userPlan }
        return nil
    }
}

public enum OnboardingRequirement: String, CaseIterable, Sendable {
    case accountSetup
    case educationalLevel
    case userPlan
}
