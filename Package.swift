// swift-tools-version:6.2

import PackageDescription

let package = Package(
  name: "swift-twitch-client",
  platforms: [.macOS(.v13), .iOS(.v16), .tvOS(.v16), .watchOS(.v9)],
  products: [.library(name: "Twitch", targets: ["Twitch"])],
  dependencies: [
    .package(
      url: "https://github.com/WeTransfer/Mocker.git", .upToNextMajor(from: "3.0.2")),
    .package(url: "https://github.com/MahdiBM/TwitchIRC", from: "1.5.0"),
    .package(url: "https://github.com/vapor/websocket-kit", from: "2.14.0"),
  ],
  targets: [
    .target(
      name: "Twitch",
      dependencies: [
        "TwitchIRC",
        .product(
          name: "WebSocketKit", package: "websocket-kit",
          condition: .when(platforms: [.linux])),
      ],
      swiftSettings: [
        .swiftLanguageMode(.v6)
      ],
    ),
    .testTarget(
      name: "TwitchTests", dependencies: ["Twitch", "Mocker"],
      resources: [
        .process("API/MockResources"),
        .process("EventSub/MockResources"),
      ]),
  ])
