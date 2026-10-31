// swift-tools-version: 5.9
import PackageDescription

// The domain model can be tested independently of SwiftUI and provider SDKs.
let package = Package(
    name: "GraduFitCore",
    platforms: [.iOS(.v17)],
    products: [.library(name: "GraduFitCore", targets: ["GraduFitCore"])],
    targets: [
        .target(name: "GraduFitCore", path: "GraduFit/Core"),
        .testTarget(name: "GraduFitCoreTests", dependencies: ["GraduFitCore"],
                    path: "CoreTests")
    ]
)
