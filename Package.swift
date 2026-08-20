// swift-tools-version: 6.1

import PackageDescription

// Every dependency resolves from its published URL. NEVER from a `../<name>` sibling.
//
// The old helper preferred a sibling checkout when one existed, so the fleet would share the
// single OCCT.xcframework instead of each repo extracting its own (SecondMouseAU/ecosystem#8).
// The saving is real but bought in the wrong currency: a path dependency carries no version
// requirement, so SwiftPM compiles whatever happens to be checked out in that sibling and drops
// the pin from Package.resolved entirely. Committing that lockfile makes the repo unresolvable
// from any clean checkout, which is CI and every new clone.
//
// Not hypothetical: PadCAM's `main` was unresolvable for exactly this reason and nobody noticed,
// because everyone builds with siblings present. Four incidents in two days built stale sibling
// source (ecosystem#48), and four OCCTParts branches shipped a Package.resolved with every
// occtswift pin stripped, caught by a review bot reading the diff rather than by any check
// (ecosystem#51).
//
// Measured, which is what settles it: the artifact DOWNLOAD is already shared, in
// ~/Library/Caches/org.swift.swiftpm/artifacts, so a URL-resolved build reports
// "Fetched ... from cache" and touches no network. Sibling resolution only ever saved the
// per-project EXTRACTION, about 594 MB in .build/artifacts/. That is disk worth paying for a
// lockfile that means what it says, and it is separately recoverable by sharing the extraction
// (symlink or APFS clone) without substituting source at all.
//
// Ed's rule, 2026-08-20: nothing resolves locally except binaries, and the binary is already
// shared by the artifact cache. The helper is kept rather than reverted to a bare
// `.package(url:)` so the call sites stay identical across the fleet.
func occtDep(_ name: String, from version: String) -> Package.Dependency {
    .package(url: "https://github.com/SecondMouseAU/\(name).git", from: Version(version)!)
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
        //
        // This repo's source now REQUIRES OCCTSwift ≥3.0.0 (bounds accessors
        // are Optional, see #44), but there is no direct OCCTSwift pin here to
        // say so: the kernel arrives through Tools. Tools' 3.0.0 repin
        // (OCCTSwiftTools#56) had not released when #44 landed, so the floor
        // below still names 1.6.1 and 3.0.0 arrives only because the newest
        // Tools in `1.6.1..<2.0.0` happens to carry it. Raise this floor to the
        // Tools release that carries OCCTSwift 3.0.0 as soon as it ships, so
        // the requirement is stated rather than left to resolution luck.
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
