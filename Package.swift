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
        // Brings in OCCTSwift and OCCTSwiftViewport transitively. Tools 1.6.0
        // adds `EdgeIdentityTable` / `VertexIdentityTable` +
        // `shapeToBodyMetadataAndIdentities(...)` (OCCTSwiftTools#43/#44),
        // closing the "edge/vertex uid minted ad hoc" gap #31 shipped with —
        // every pickable kind now gets durable identity from a real
        // tessellation-time table, not just faces. See #31, #33. Tools 1.6.1
        // re-pins OCCTSwift to ≥1.15.0, where `TopologyGraph` was renamed to
        // `BRepGraph` (OCCTSwift#333) — required now that this repo's own
        // code names `BRepGraph` directly rather than the deprecated
        // typealias. See #37.
        occtDep("OCCTSwiftTools", from: "1.6.1"),
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
