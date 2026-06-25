// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "XCResource",
    products: [
        .plugin(name: "Generate Resource Code", targets: ["Generate Resource Code"]),
    ],
    targets: [
        .plugin(
            name: "Generate Resource Code",
            capability: .command(
                intent: .custom(
                    verb: "generate-resource-code",
                    description: "Generate source code for resources"),
                permissions: [
                    .writeToPackageDirectory(
                        reason: "Generate Swift source files for accessing resources")
                ]),
            dependencies: ["xcresource"],
            path: "Plugins/GenerateResourceCode"),
        .binaryTarget(
            name: "xcresource",
            url: "https://github.com/nearfri/XCResource/releases/download/1.1.7/xcresource.artifactbundle.zip",
            checksum: "f284237cccd1b30c5ff18c638d5a2005e4ecd5a1cfb0e39fdc2444f54e633f26"
        ),
    ]
)
