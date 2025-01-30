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
            url: "https://github.com/nearfri/XCResource/releases/download/0.12.0/xcresource.artifactbundle.zip",
            checksum: "80d8a2930d2b5b55abfc134e1e647a5c77fc8a6b42a22f005e17bf71121a67f2"
        ),
    ]
)
