import SwiftUI
import GoogleSignIn

@main
struct GraduFitApp: App {
    init() {
        FirebaseAuthenticationClient.configureIfAvailable()
    }

    var body: some Scene {
        WindowGroup {
            OnboardingRootView()
                .onOpenURL { url in
                    _ = GIDSignIn.sharedInstance.handle(url)
                }
        }
    }
}
