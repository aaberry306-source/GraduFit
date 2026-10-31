import XCTest
#if canImport(GraduFitCore)
@testable import GraduFitCore
#else
@testable import GraduFit
#endif

final class OnboardingProgressTests: XCTestCase {
    func testNewUserStartsAtAccountSetup() {
        XCTAssertEqual(OnboardingProgress().nextRequirement, .accountSetup)
    }

    func testAccountCompletionDoesNotCompleteFutureModules() {
        let progress = OnboardingProgress(accountSetupComplete: true)
        XCTAssertEqual(progress.nextRequirement, .educationalLevel)
        XCTAssertFalse(progress.educationalLevelComplete)
        XCTAssertFalse(progress.userPlanComplete)
    }

    func testRouterSelectsFirstIncompleteRequirementForEveryCombination() {
        for account in [false, true] {
            for education in [false, true] {
                for plan in [false, true] {
                    let progress = OnboardingProgress(
                        accountSetupComplete: account,
                        educationalLevelComplete: education,
                        userPlanComplete: plan
                    )
                    let expected: OnboardingRequirement? = !account ? .accountSetup
                        : !education ? .educationalLevel : !plan ? .userPlan : nil
                    XCTAssertEqual(progress.nextRequirement, expected,
                                   "account=\(account), education=\(education), plan=\(plan)")
                }
            }
        }
    }
}
