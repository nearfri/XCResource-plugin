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
            url: "https://github.com/nearfri/XCResource/releases/download/0.10.1/xcresource.artifactbundle.zip",
            checksum: "3325c5c420efcb75e0531e9b6a1aa740ee0c4fd8c68a9534708c01a4fb73d3f9"
        ),
    ]
)
