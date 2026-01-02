// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ZenOrigami",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "ZenOrigami",
            targets: ["ZenOrigami"]
        )
    ],
    dependencies: [
        // Supabase Swift SDK
        .package(url: "https://github.com/supabase/supabase-swift.git", from: "2.0.0"),
    ],
    targets: [
        .target(
            name: "ZenOrigami",
            dependencies: [
                .product(name: "Supabase", package: "supabase-swift"),
            ],
            path: "ZenOrigami"
        ),
        .testTarget(
            name: "ZenOrigamiTests",
            dependencies: ["ZenOrigami"],
            path: "Tests"
        )
    ]
)
