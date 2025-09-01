import Foundation

@testable import Twitch

struct MockedMessages {
  // Helix response for creating a subscription
  static let mockEventSubSubscription = String(
    data: Bundle.module.url(
      forResource: "mockEventSubSubscription", withExtension: "json")!.data,
    encoding: .utf8)!

  // MARK: - EventSub Messages

  static let welcomeMessage = String(
    data: Bundle.module.url(forResource: "welcomeMessage", withExtension: "json")!.data,
    encoding: .utf8)!

  static let welcomeMessage1SecondKeepalive = String(
    data: Bundle.module.url(
      forResource: "welcomeMessage1SecondKeepalive", withExtension: "json")!.data,
    encoding: .utf8)!

  static let mockRevocationMessage = String(
    data: Bundle.module.url(forResource: "revocationMessage", withExtension: "json")!
      .data,
    encoding: .utf8)!

  static let mockReconnectMessage = String(
    data: Bundle.module.url(forResource: "reconnectMessage", withExtension: "json")!
      .data,
    encoding: .utf8)!

  static let mockEventMessage = String(
    data: Bundle.module.url(forResource: "mockEventMessage", withExtension: "json")!.data,
    encoding: .utf8)!

  // MARK: - Automod Messages

  static let automodMessageHold = String(
    data: Bundle.module.url(forResource: "automodMessageHold", withExtension: "json")!
      .data,
    encoding: .utf8)!

  static let automodMessageUpdate = String(
    data: Bundle.module.url(forResource: "automodMessageUpdate", withExtension: "json")!
      .data,
    encoding: .utf8)!

  static let automodSettingsUpdate = String(
    data: Bundle.module.url(forResource: "automodSettingsUpdate", withExtension: "json")!
      .data,
    encoding: .utf8)!

  static let automodTermsUpdate = String(
    data: Bundle.module.url(forResource: "automodTermsUpdate", withExtension: "json")!
      .data,
    encoding: .utf8)!
}
