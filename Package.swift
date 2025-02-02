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
            url: "https://github.com/nearfri/XCResource/releases/download/1.0.0/xcresource.artifactbundle.zip",
            checksum: "98fe94dde97cc792876e6d4dd3f6d508f882c23ce8d54ee7e21ff233a7005c4a"
        ),
    ]
)
