public protocol Event: Decodable, Sendable {}

internal enum EventType: String, Decodable {
  // MARK: - Automod

  case automodMessageHold = "automod.message.hold"
  case automodMessageUpdate = "automod.message.update"
  case automodSettingsUpdate = "automod.settings.update"
  case automodTermsUpdate = "automod.terms.update"

  // MARK: - Channel

  // Bits
  case channelBitsUse = "channel.bits.use"
  case channelCheer = "channel.cheer"

  case channelFollow = "channel.follow"
  case chatMessage = "channel.chat.message"
  case channelUpdate = "channel.update"
  case chatClear = "channel.chat.clear"

  case mock = "mock"

  var event: Event.Type {
    switch self {
    // Automod
    case .automodMessageHold: return AutomodMessageHoldEvent.self
    case .automodMessageUpdate: return AutomodMessageUpdateEvent.self
    case .automodSettingsUpdate: return AutomodSettingsUpdateEvent.self
    case .automodTermsUpdate: return AutomodTermsUpdateEvent.self

    //// Channel

    // Bits
    case .channelBitsUse: return ChannelBitsUseEvent.self
    case .channelCheer: return ChannelCheerEvent.self

    case .channelFollow: return ChannelFollowEvent.self
    case .chatMessage: return ChatMessageEvent.self
    case .channelUpdate: return ChannelUpdateEvent.self
    case .chatClear: return ChatClearEvent.self

    case .mock: return MockEvent.self
    }
  }
}

struct MockEvent: Event {}
