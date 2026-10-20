// swift-tools-version:6.4

import PackageDescription

#if os(Linux)
  // String catalogs require Apple's tooling; Linux uses plain error descriptions.
  let twitchExcludes = ["Localizable.xcstrings"]
  let twitchResources: [Resource] = []
#else
  let twitchExcludes: [String] = []
  let twitchResources: [Resource] = [.process("Localizable.xcstrings")]
#endif

let package = Package(
  name: "swift-twitch-client",
  defaultLocalization: "en",
  platforms: [.macOS(.v13), .iOS(.v16), .tvOS(.v16), .watchOS(.v9)],
  products: [.library(name: "Twitch", targets: ["Twitch"])],
  dependencies: [
    .package(
      url: "https://github.com/MahdiBM/TwitchIRC",
      .upToNextMajor(from: "1.6.0")),

    .package(
      url: "https://github.com/gohanlon/swift-memberwise-init-macro",
      .upToNextMajor(from: "0.6.0")),
  ],
  targets: [
    .target(
      name: "Twitch",
      dependencies: [
        "TwitchIRC",
        .product(name: "MemberwiseInit", package: "swift-memberwise-init-macro"),
      ],
      exclude: twitchExcludes,
      resources: twitchResources,
      swiftSettings: [.swiftLanguageMode(.v6)],
    ),
    .testTarget(
      name: "TwitchTests", dependencies: ["Twitch"],
      resources: [
        .process("API/MockResources"),
        .process("EventSub/MockResources"),
      ]),
  ])
