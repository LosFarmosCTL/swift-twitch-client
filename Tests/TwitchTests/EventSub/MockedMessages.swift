import Foundation

@testable import Twitch

struct MockedMessages {
  // Helix response for creating a subscription
  static let mockEventSubSubscription = Bundle.module.url(
    forResource: "mockEventSubSubscription", withExtension: "json")!.data

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
}
