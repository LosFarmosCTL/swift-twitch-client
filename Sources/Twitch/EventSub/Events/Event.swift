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

  // MARK: - Charity
  case charityDonation = "channel.charity_campaign.donate"
  case charityCampaignStart = "channel.charity_campaign.start"
  case charityCampaignProgress = "channel.charity_campaign.progress"
  case charityCampaignStop = "channel.charity_campaign.stop"

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

    //// Charity

    case .charityDonation: return CharityDonationEvent.self
    case .charityCampaignStart: return CharityCampaignStartEvent.self
    case .charityCampaignProgress: return CharityCampaignProgressEvent.self
    case .charityCampaignStop: return CharityCampaignStopEvent.self

    case .mock: return MockEvent.self
    }
  }
}

struct MockEvent: Event {}
