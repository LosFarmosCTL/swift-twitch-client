public protocol Event: Decodable, Sendable {}

internal enum EventType: String, Decodable {
  // Automod
  case automodMessageHold = "automod.message.hold"
  case automodMessageUpdate = "automod.message.update"
  case automodSettingsUpdate = "automod.settings.update"
  case automodTermsUpdate = "automod.terms.update"

  // Channel
  case channelFollow = "channel.follow"
  case chatMessage = "channel.chat.message"
  case channelUpdate = "channel.update"
  case chatClear = "channel.chat.clear"

  case mock = "mock"

  var event: Event.Type {
    switch self {
    case .automodMessageHold: return AutomodMessageHoldEvent.self
    case .automodMessageUpdate: return AutomodMessageUpdateEvent.self
    case .automodSettingsUpdate: return AutomodSettingsUpdateEvent.self
    case .automodTermsUpdate: return AutomodTermsUpdateEvent.self

    case .channelFollow: return ChannelFollowEvent.self
    case .chatMessage: return ChatMessageEvent.self
    case .channelUpdate: return ChannelUpdateEvent.self
    case .chatClear: return ChatClearEvent.self

    case .mock: return MockEvent.self
    }
  }
}

struct MockEvent: Event {}
