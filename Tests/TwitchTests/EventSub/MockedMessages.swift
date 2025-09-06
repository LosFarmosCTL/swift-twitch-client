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

  // Ads
  static let channelAdBreakBegin = fromResource("channelAdBreakBegin")

  // Chat
  static let channelChatClear = fromResource("channelChatClear")
  static let channelChatClearUserMessages = fromResource("channelChatClearUserMessages")
  static let channelChatMessage = fromResource("channelChatMessage")
  static let channelChatMessageDelete = fromResource("channelChatMessageDelete")
  static let channelChatNotification = fromResource("channelChatNotification")
  static let channelChatNotificationSharedChat = fromResource(
    "channelChatNotificationSharedChat")
  static let channelChatSettingsUpdate = fromResource("channelChatSettingsUpdate")
  static let channelChatUserMessageHold = fromResource("channelChatUserMessageHold")
  static let channelChatUserMessageUpdate = fromResource("channelChatUserMessageUpdate")

  // Shared Chat
  static let channelSharedChatSessionBegin = fromResource("channelSharedChatSessionBegin")
  static let channelSharedChatSessionUpdate = fromResource(
    "channelSharedChatSessionUpdate")
  static let channelSharedChatSessionEnd = fromResource("channelSharedChatSessionEnd")

  // Subscriptions
  static let channelSubscribe = fromResource("channelSubscribe")
  static let channelSubscriptionEnd = fromResource("channelSubscriptionEnd")
  static let channelSubscriptionGift = fromResource("channelSubscriptionGift")
  static let channelSubscriptionMessage = fromResource("channelSubscriptionMessage")

  // Guest Star
  static let channelGuestStarSessionBegin = fromResource("channelGuestStarSessionBegin")
  static let channelGuestStarSessionEnd = fromResource("channelGuestStarSessionEnd")
  static let channelGuestStarGuestUpdate = fromResource("channelGuestStarGuestUpdate")
  static let channelGuestStarSettingsUpdate = fromResource(
    "channelGuestStarSettingsUpdate")

  // Shoutouts
  static let channelShoutoutCreate = fromResource("channelShoutoutCreate")
  static let channelShoutoutReceive = fromResource("channelShoutoutReceive")

  // Channel Points
  static let channelPointsCustomRewardAdd = fromResource("channelPointsCustomRewardAdd")
  static let channelPointsCustomRewardUpdate = fromResource(
    "channelPointsCustomRewardUpdate")
  static let channelPointsCustomRewardRemove = fromResource(
    "channelPointsCustomRewardRemove")
  static let channelPointsCustomRewardRedemptionAdd = fromResource(
    "channelPointsCustomRewardRedemptionAdd")
  static let channelPointsCustomRewardRedemptionUpdate = fromResource(
    "channelPointsCustomRewardRedemptionUpdate")
  static let channelPointsAutomaticRewardRedemptionAdd = fromResource(
    "channelPointsAutomaticRewardRedemptionAdd")

  // VIPs
  static let channelVIPAdd = fromResource("channelVIPAdd")
  static let channelVIPRemove = fromResource("channelVIPRemove")

  // Polls
  static let channelPollBegin = fromResource("channelPollBegin")
  static let channelPollProgress = fromResource("channelPollProgress")
  static let channelPollEnd = fromResource("channelPollEnd")

  // Predictions
  static let channelPredictionBegin = fromResource("channelPredictionBegin")
  static let channelPredictionProgress = fromResource("channelPredictionProgress")
  static let channelPredictionLock = fromResource("channelPredictionLock")
  static let channelPredictionEnd = fromResource("channelPredictionEnd")

  // Charity
  static let charityDonation = fromResource("charityDonation")
  static let charityCampaignStart = fromResource("charityCampaignStart")
  static let charityCampaignProgress = fromResource("charityCampaignProgress")
  static let charityCampaignStop = fromResource("charityCampaignStop")

  // MARK: - Stream Messages

  static let streamOnline = fromResource("streamOnline")
  static let streamOffline = fromResource("streamOffline")

  // MARK: - User Messages

  static let userUpdate = fromResource("userUpdate")

  // MARK: - Whisper Messages

  static let whisperReceived = fromResource("whisperReceived")

  static private func fromResource(_ name: String) -> String {
    String(
      data: Bundle.module.url(forResource: name, withExtension: "json")!.data,
      encoding: .utf8)!
  }
}
