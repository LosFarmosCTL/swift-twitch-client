import Foundation

@testable import Twitch

enum MockedMessages {
  // Helix response for creating a subscription
  static let mockEventSubSubscription = fromResource("mockEventSubSubscription")

  // MARK: - EventSub Messages

  static let welcomeMessage = fromResource("welcomeMessage")
  static let welcomeMessage1SecondKeepalive = fromResource(
    "welcomeMessage1SecondKeepalive")
  static let mockRevocationMessage = fromResource("revocationMessage")
  static let mockReconnectMessage = fromResource("reconnectMessage")
  static let mockEventMessage = fromResource("mockEventMessage")

  // MARK: - Automod Messages

  static let automodMessageHold = fromResource("automodMessageHold")
  static let automodMessageUpdate = fromResource("automodMessageUpdate")
  static let automodSettingsUpdate = fromResource("automodSettingsUpdate")
  static let automodTermsUpdate = fromResource("automodTermsUpdate")

  // MARK: - Channel Messages

  // General
  static let channelUpdate = fromResource("channelUpdate")
  static let channelFollow = fromResource("channelFollow")
  static let channelRaid = fromResource("channelRaid")

  // Bits
  static let channelBitsUse = fromResource("channelBitsUse")
  static let channelCheer = fromResource("channelCheer")

  static private func fromResource(_ name: String) -> String {
    String(
      data: Bundle.module.url(forResource: name, withExtension: "json")!.data,
      encoding: .utf8)!
  }
}
