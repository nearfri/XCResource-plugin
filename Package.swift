// swift-tools-version: 5.9
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
            url: "https://github.com/nearfri/XCResource/releases/download/0.11.2/xcresource.artifactbundle.zip",
            checksum: "c560ae7f6b9432957ca740abbdaa2e8b488320227b3ff9c4ec720ea6062b72d5"
        ),
    ]
)
