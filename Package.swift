// swift-tools-version:5.7

import PackageDescription

let package = Package(
  name: "swift-twitch-client",
  products: [
    .library(
      name: "Twitch",
      targets: ["Twitch"]
    )
  ],
  dependencies: [],
  targets: [
    .target(name: "Twitch"),
    .testTarget(
      name: "TwitchTests",
      dependencies: ["Twitch"]
    ),
  ]
)
