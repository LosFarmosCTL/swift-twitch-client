public protocol Event: Decodable, Sendable {}

internal enum EventType: String, Decodable {
  // MARK: - Automod

  case automodMessageHold = "automod.message.hold"
  case automodMessageUpdate = "automod.message.update"
  case automodSettingsUpdate = "automod.settings.update"
  case automodTermsUpdate = "automod.terms.update"

  // MARK: - Channel

  // General
  case channelUpdate = "channel.update"
  case channelFollow = "channel.follow"
  case channelRaid = "channel.raid"

  // Bits
  case channelBitsUse = "channel.bits.use"
  case channelCheer = "channel.cheer"

  // Ads
  case channelAdBreakBegin = "channel.ad_break.begin"

  // Chat
  case channelChatClear = "channel.chat.clear"
  case channelChatClearUserMessages = "channel.chat.clear_user_messages"
  case channelChatMessage = "channel.chat.message"
  case channelChatMessageDelete = "channel.chat.message_delete"
  case channelChatNotification = "channel.chat.notification"
  case channelChatSettingsUpdate = "channel.chat_settings.update"
  case channelChatUserMessageHold = "channel.chat.user_message_hold"
  case channelChatUserMessageUpdate = "channel.chat.user_message_update"

  // Shared Chat
  case channelSharedChatSessionBegin = "channel.shared_chat.begin"
  case channelSharedChatSessionUpdate = "channel.shared_chat.update"
  case channelSharedChatSessionEnd = "channel.shared_chat.end"

  // Subscriptions
  case channelSubscribe = "channel.subscribe"
  case channelSubscriptionEnd = "channel.subscription.end"
  case channelSubscriptionGift = "channel.subscription.gift"
  case channelSubscriptionMessage = "channel.subscription.message"

  // Guest Star
  case channelGuestStarSessionBegin = "channel.guest_star_session.begin"
  case channelGuestStarSessionEnd = "channel.guest_star_session.end"
  case channelGuestStarGuestUpdate = "channel.guest_star_guest.update"
  case channelGuestStarSettingsUpdate = "channel.guest_star_settings.update"

  // Shoutouts
  case channelShoutoutCreate = "channel.shoutout.create"
  case channelShoutoutReceive = "channel.shoutout.receive"

  // Channel Points
  case channelPointsCustomRewardAdd = "channel.channel_points_custom_reward.add"
  case channelPointsCustomRewardUpdate = "channel.channel_points_custom_reward.update"
  case channelPointsCustomRewardRemove = "channel.channel_points_custom_reward.remove"
  case channelPointsCustomRewardRedemptionAdd =
    "channel.channel_points_custom_reward_redemption.add"
  case channelPointsCustomRewardRedemptionUpdate =
    "channel.channel_points_custom_reward_redemption.update"
  case channelPointsAutomaticRewardRedemptionAdd =
    "channel.channel_points_automatic_reward_redemption.add"

  // VIPs
  case channelVIPAdd = "channel.vip.add"
  case channelVIPRemove = "channel.vip.remove"

  // Polls
  case channelPollBegin = "channel.poll.begin"
  case channelPollProgress = "channel.poll.progress"
  case channelPollEnd = "channel.poll.end"

  // Predictions
  case channelPredictionBegin = "channel.prediction.begin"
  case channelPredictionProgress = "channel.prediction.progress"
  case channelPredictionLock = "channel.prediction.lock"
  case channelPredictionEnd = "channel.prediction.end"

  // Charity
  case charityDonation = "channel.charity_campaign.donate"
  case charityCampaignStart = "channel.charity_campaign.start"
  case charityCampaignProgress = "channel.charity_campaign.progress"
  case charityCampaignStop = "channel.charity_campaign.stop"

  // MARK: - Stream
  case streamOnline = "stream.online"
  case streamOffline = "stream.offline"

  // MARK: - User
  case userUpdate = "user.update"

  // MARK: - Whisper
  case whisperReceived = "user.whisper.message"

  case mock = "mock"

  var event: Event.Type {
    switch self {
    // Automod
    case .automodMessageHold: return AutomodMessageHoldEvent.self
    case .automodMessageUpdate: return AutomodMessageUpdateEvent.self
    case .automodSettingsUpdate: return AutomodSettingsUpdateEvent.self
    case .automodTermsUpdate: return AutomodTermsUpdateEvent.self

    //// Channel

    // General
    case .channelUpdate: return ChannelUpdateEvent.self
    case .channelFollow: return ChannelFollowEvent.self
    case .channelRaid: return ChannelRaidEvent.self

    // Bits
    case .channelBitsUse: return ChannelBitsUseEvent.self
    case .channelCheer: return ChannelCheerEvent.self

    // Ads
    case .channelAdBreakBegin: return ChannelAdBreakBeginEvent.self

    // Chat
    case .channelChatClear: return ChannelChatClearEvent.self
    case .channelChatClearUserMessages: return ChannelChatClearUserMessagesEvent.self
    case .channelChatMessage: return ChannelChatMessageEvent.self
    case .channelChatMessageDelete: return ChannelChatMessageDeleteEvent.self
    case .channelChatNotification: return ChannelChatNotificationEvent.self
    case .channelChatSettingsUpdate: return ChannelChatSettingsUpdateEvent.self
    case .channelChatUserMessageHold: return ChannelChatUserMessageHoldEvent.self
    case .channelChatUserMessageUpdate: return ChannelChatUserMessageUpdateEvent.self

    // Shared Chat
    case .channelSharedChatSessionBegin: return ChannelSharedChatSessionBeginEvent.self
    case .channelSharedChatSessionUpdate: return ChannelSharedChatSessionUpdateEvent.self
    case .channelSharedChatSessionEnd: return ChannelSharedChatSessionEndEvent.self

    // Subscriptions
    case .channelSubscribe: return ChannelSubscribeEvent.self
    case .channelSubscriptionEnd: return ChannelSubscriptionEndEvent.self
    case .channelSubscriptionGift: return ChannelSubscriptionGiftEvent.self
    case .channelSubscriptionMessage: return ChannelSubscriptionMessageEvent.self

    // Guest Star
    case .channelGuestStarSessionBegin: return ChannelGuestStarSessionBeginEvent.self
    case .channelGuestStarSessionEnd: return ChannelGuestStarSessionEndEvent.self
    case .channelGuestStarGuestUpdate: return ChannelGuestStarGuestUpdateEvent.self
    case .channelGuestStarSettingsUpdate: return ChannelGuestStarSettingsUpdateEvent.self

    // Shoutouts
    case .channelShoutoutCreate: return ChannelShoutoutCreateEvent.self
    case .channelShoutoutReceive: return ChannelShoutoutReceiveEvent.self

    // Channel Points
    case .channelPointsCustomRewardAdd: return ChannelPointsCustomRewardAddEvent.self
    case .channelPointsCustomRewardUpdate:
      return ChannelPointsCustomRewardUpdateEvent.self
    case .channelPointsCustomRewardRemove:
      return ChannelPointsCustomRewardRemoveEvent.self
    case .channelPointsCustomRewardRedemptionAdd:
      return ChannelPointsCustomRewardRedemptionAddEvent.self
    case .channelPointsCustomRewardRedemptionUpdate:
      return ChannelPointsCustomRewardRedemptionUpdateEvent.self
    case .channelPointsAutomaticRewardRedemptionAdd:
      return ChannelPointsAutomaticRewardRedemptionAddEvent.self

    // VIPs
    case .channelVIPAdd: return ChannelVIPAddEvent.self
    case .channelVIPRemove: return ChannelVIPRemoveEvent.self

    // Polls
    case .channelPollBegin: return ChannelPollBeginEvent.self
    case .channelPollProgress: return ChannelPollProgressEvent.self
    case .channelPollEnd: return ChannelPollEndEvent.self

    // Predictions
    case .channelPredictionBegin: return ChannelPredictionBeginEvent.self
    case .channelPredictionProgress: return ChannelPredictionProgressEvent.self
    case .channelPredictionLock: return ChannelPredictionLockEvent.self
    case .channelPredictionEnd: return ChannelPredictionEndEvent.self

    // Charity
    case .charityDonation: return CharityDonationEvent.self
    case .charityCampaignStart: return CharityCampaignStartEvent.self
    case .charityCampaignProgress: return CharityCampaignProgressEvent.self
    case .charityCampaignStop: return CharityCampaignStopEvent.self

    //// Stream

    case .streamOnline: return StreamOnlineEvent.self
    case .streamOffline: return StreamOfflineEvent.self

    //// User

    case .userUpdate: return UserUpdateEvent.self

    //// Whisper

    case .whisperReceived: return WhisperReceivedEvent.self

    case .mock: return MockEvent.self
    }
  }
}

struct MockEvent: Event {}
