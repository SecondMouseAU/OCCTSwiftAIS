// swift-tools-version: 6.1

import PackageDescription
import Foundation

// Prefer a local sibling checkout (../<name>) when present, else the published URL — so the whole
// OCCT ecosystem SHARES the single OCCTSwift/Libraries/OCCT.xcframework instead of each repo
// extracting its own 1.3 GB copy. CI / fresh clones (no sibling) use the URL pin. `#filePath`-relative
// so it's independent of build CWD.
func occtDep(_ name: String, from version: String) -> Package.Dependency {
    let manifestDir = URL(fileURLWithPath: #filePath).deletingLastPathComponent().path
    // Only trust a sibling checkout for a REAL local dev clone — never when this manifest is itself a
    // transitively-resolved checkout under a consumer's `.build/checkouts/` (SwiftPM lays every dep out
    // flat there, so `../\(name)` spuriously exists and flips this to a path dep → a SwiftPM identity
    // conflict with the URL-based dep. See SecondMouseAU/ecosystem#14.
    if !manifestDir.contains("/.build/"),
       FileManager.default.fileExists(atPath: manifestDir + "/../\(name)/Package.swift") {
        return .package(path: "../\(name)")
    }
    return .package(url: "https://github.com/SecondMouseAU/\(name).git", from: Version(version)!)
}

let package = Package(
    name: "OCCTSwiftAIS",
    platforms: [
        .iOS(.v18),
        .macOS(.v15),
        .visionOS(.v1),
        .tvOS(.v18)
    ],
    products: [
        .library(
            name: "OCCTSwiftAIS",
            targets: ["OCCTSwiftAIS"]
        ),
    ],
    dependencies: [
        // Brings in OCCTSwift and OCCTSwiftViewport transitively. Tools 1.5.0
        // re-pins the cohort onto current OCCTSwift (1.12.9+) and ships
        // `shapeToBodyMetadataAndIdentity(...graph:)` + `FaceIdentityTable`
        // (OCCTSwiftTools#42), which durable sub-shape identity in this repo
        // (`SubShapeRef.uid`, `InteractiveContext.update`/`remap`) is built on
        // — see #31.
        occtDep("OCCTSwiftTools", from: "1.5.0"),
    ],
    targets: [
        .target(
            name: "OCCTSwiftAIS",
            dependencies: [
                .product(name: "OCCTSwiftTools", package: "OCCTSwiftTools"),
            ],
            path: "Sources/OCCTSwiftAIS",
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]
        ),
        .testTarget(
            name: "OCCTSwiftAISTests",
            dependencies: ["OCCTSwiftAIS"],
            path: "Tests/OCCTSwiftAISTests",
            resources: [
                .copy("Fixtures")
            ]
        ),
    ]
)
