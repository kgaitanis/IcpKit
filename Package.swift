// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "IcpKit",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
        .macCatalyst(.v16),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(name: "IcpKit", targets: ["IcpKit"]),
        .library(name: "Candid", targets: ["Candid"]),
        .library(name: "DAB", targets: ["DAB"]),
        .executable(name: "CodeGenerator", targets: ["CodeGenerator"]),
        //.library(name: "Bls12381", targets: ["bls12381"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/attaswift/BigInt.git", .upToNextMajor(from: "5.7.0")),
        .package(url: "https://github.com/outfoxx/PotentCodables.git", .upToNextMajor(from: "3.2.0")),
        .package(url: "https://github.com/swift-libp2p/swift-bases.git", .upToNextMajor(from: "0.0.1")),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.0"),
        .package(url: "https://github.com/GigaBitcoin/secp256k1.swift.git", exact: "0.10.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "IcpKit",
            dependencies: [
                "Candid",
                "BigInt",
                .product(name: "PotentCodables", package: "PotentCodables"),
                .product(name: "secp256k1", package: "secp256k1.swift"),
//                .target(name: "bls12381"),
            ]
//            cSettings: [.headerSearchPath("Sources/bls12381/include"),
//                        .unsafeFlags(["-ISources/bls12381/include/Bls12381.h"])],
//            cxxSettings: [.headerSearchPath("Sources/bls12381/include"),
//                          .unsafeFlags(["-ISources/bls12381/include/Bls12381.h"])]
        ),
        .target(
            name: "Candid",
            dependencies: [
                "PotentCodables",
                .product(name: "Base32", package: "swift-bases"),
            ]
        ),
        .target(
            name: "DAB",
            dependencies: [
                "IcpKit",
            ]
        ),
        .executableTarget(
            name: "CodeGenerator",
            dependencies: [
                "Candid",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
//        .binaryTarget(
//            name: "bls12381",
//            path: "Binaries/Bls12381.xcframework"
//        ),
        .testTarget(
            name: "IcpKitTests",
            dependencies: ["IcpKit",]
        ),
        .testTarget(
            name: "CandidTests",
            dependencies: ["Candid"]
        ),
        .testTarget(
            name: "CodeGeneratorTests",
            dependencies: ["CodeGenerator", "Candid", "IcpKit"],
            resources: [
                .process("DidFiles/ICRC7.did"),
                .process("DidFiles/GoldNFT.did"),
                .process("DidFiles/EVMProviders.did"),
                .process("DidFiles/LedgerCanister.did"),
                .process("DidFiles/TestImports.did"),
                .process("DidFiles/TestImports2.did"),
                .process("Generated/LedgerCanister.did.generated_swift"),
                .process("Generated/ICRC7.did.generated_swift"),
                .process("Generated/GoldNFT.did.generated_swift"),
                .process("Generated/TestCodeGeneration.did.generated_swift"),
                .process("Generated/TestImports.did.generated_swift"),
                .process("Generated/EVMProviders.did.generated_swift"),
            ]
        ),
        .testTarget(
            name: "DABTests",
            dependencies: ["Candid", "IcpKit", "DAB"]
        ),
    ],
    swiftLanguageModes: [.v6]
)
