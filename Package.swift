// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Underneath",
  platforms: [
    .macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6), .visionOS(.v1),
  ],
  products: [
    // Products define the executables and libraries a package produces, making them visible to other packages.
    .library(name: "Underneath", targets: ["Underneath"])
  ],
  dependencies: [
    .package(url: "https://github.com/devicekit/DeviceKit", .upToNextMajor(from: "5.6.0")),
    .package(url: "https://github.com/apple/swift-log.git", .upToNextMajor(from: "1.6.3")),
    .package(url: "https://github.com/sushichop/Puppy.git", .upToNextMajor(from: "0.9.0")),
    .package(url: "https://github.com/hmlongco/Factory", .upToNextMajor(from: "2.5.3")),
  ],
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .target(
      name: "Underneath",
      dependencies: [
        .product(name: "Puppy", package: "Puppy"),
        .product(name: "Logging", package: "swift-log"),
        .product(name: "Factory", package: "Factory"),
        .product(name: "DeviceKit", package: "DeviceKit"),
      ],
    ),
    .testTarget(
      name: "UnderneathTests",
      dependencies: ["Underneath"],
    ),
  ]
)
