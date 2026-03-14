// swift-tools-version:6.2

import PackageDescription

let package = Package(
  name: "swift-twitch-client",
  defaultLocalization: "en",
  platforms: [.macOS(.v13), .iOS(.v16), .tvOS(.v16), .watchOS(.v9)],
  products: [.library(name: "Twitch", targets: ["Twitch"])],
  dependencies: [
    .package(
      url: "https://github.com/WeTransfer/Mocker.git",
      .upToNextMajor(from: "3.0.2")),

    .package(
      url: "https://github.com/MahdiBM/TwitchIRC",
      .upToNextMajor(from: "1.6.0")),

    .package(
      url: "https://github.com/gohanlon/swift-memberwise-init-macro",
      .upToNextMajor(from: "0.5.2")),
  ],
  targets: [
    .target(
      name: "Twitch",
      dependencies: [
        "TwitchIRC",
        .product(name: "MemberwiseInit", package: "swift-memberwise-init-macro"),
      ],
      resources: [.process("Localizable.xcstrings")],
      swiftSettings: [.swiftLanguageMode(.v6)],
    ),
    .testTarget(
      name: "TwitchTests", dependencies: ["Twitch", "Mocker"],
      resources: [
        .process("API/MockResources"),
        .process("EventSub/MockResources"),
      ]),
  ])
