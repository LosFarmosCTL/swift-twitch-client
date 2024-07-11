public protocol Event: Decodable {}

internal enum EventType: String, Decodable {
  case channelFollow = "channel.follow"
  case chatMessage = "channel.chat.message"
  case channelUpdate = "channel.update"
  case chatClear = "channel.chat.clear"

  var event: Event.Type {
    switch self {
    case .channelFollow: return ChannelFollowEvent.self
    case .chatMessage: return ChatMessageEvent.self
    case .channelUpdate: return ChannelUpdateEvent.self
    case .chatClear: return ChatClearEvent.self
    }
  }
}
