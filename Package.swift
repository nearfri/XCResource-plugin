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
                    description: "Generate source code for resources."),
                permissions: [
                    .writeToPackageDirectory(
                        reason: "Generate and write source code into the package direcotry")
                ]),
            dependencies: ["xcresource"],
            path: "Plugins/GenerateResourceCode"),
        .binaryTarget(
            name: "xcresource",
            url: "https://github.com/nearfri/XCResource/releases/download/0.11.5/xcresource.artifactbundle.zip",
            checksum: "94316fa98b2cccf98f5b607adbf842904751b684a5fea9fb1c2077baf9853ea0"
        ),
    ]
)
