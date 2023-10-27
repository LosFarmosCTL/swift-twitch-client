// swift-tools-version:5.9

import PackageDescription

let package = Package(
  name: "swift-twitch-client",
  platforms: [.macOS(.v12), .iOS(.v15), .tvOS(.v15), .watchOS(.v8)],
  products: [.library(name: "Twitch", targets: ["Twitch"])],
  dependencies: [
    .package(
      url: "https://github.com/WeTransfer/Mocker.git",
      .upToNextMajor(from: "3.0.1")),
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
      ]),
    .testTarget(
      name: "TwitchTests", dependencies: ["Twitch", "Mocker"],
      resources: [.process("API/MockResources")]),
  ])
