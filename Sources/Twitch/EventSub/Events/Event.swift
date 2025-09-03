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

    case .mock: return MockEvent.self
    }
  }
}

struct MockEvent: Event {}
