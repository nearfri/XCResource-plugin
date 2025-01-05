// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "XCResource",
    products: [
        .plugin(name: "RunXCResource", targets: ["RunXCResource"]),
    ],
    targets: [
        .plugin(
            name: "RunXCResource",
            capability: .command(
                intent: .custom(
                    verb: "run-xcresource",
                    description: "Run XCResource to generate symbols for assets or strings."),
                permissions: [
                    .writeToPackageDirectory(
                        reason: "Write symbol files in the package direcotry")
                ]),
            dependencies: ["xcresource"]),
        .binaryTarget(
            name: "xcresource",
            url: "https://github.com/nearfri/XCResource/releases/download/0.11.4/xcresource.artifactbundle.zip",
            checksum: "1ec36153713b415f2a3053751144982bfc90ca2ce7ddc7c5afcce089d1f20bca"
        ),
    ]
)
