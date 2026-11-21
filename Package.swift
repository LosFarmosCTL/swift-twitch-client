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
  platforms: [.macOS(.v13), .iOS(.v16), .tvOS(.v16), .watchOS(.v9), .visionOS(.v1)],
  products: [.library(name: "Twitch", targets: ["Twitch"])],
  dependencies: [
    .package(
      url: "https://github.com/LosFarmosCTL/TwitchIRC",
      .upToNextMajor(from: "2.1.0"))
  ],
  targets: [
    .target(
      name: "Twitch",
      dependencies: ["TwitchIRC"],
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
