import Foundation

internal struct EventSubMessage: Decodable {
  // let id: String
  let timestamp: Date

  let payload: EventSubPayload

  enum CodingKeys: String, CodingKey {
    case metadata, payload
  }

  init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    let metadata = try container.decode(Metadata.self, forKey: .metadata)

    // self.id = metadata.id
    self.timestamp = metadata.timestamp

    // depending on the type of message, we need to decode a different payload
    switch metadata.type {
    case .welcome:
      self.payload = .welcome(
        try container.decode(EventSubWelcome.self, forKey: .payload))
    case .keepalive:
      self.payload = .keepalive
    case .notification:
      self.payload = .notification(
        try container.decode(EventSubNotification.self, forKey: .payload))
    case .reconnect:
      self.payload = .reconnect(
        try container.decode(EventSubReconnect.self, forKey: .payload))
    case .revocation:
      self.payload = .revocation(
        try container.decode(EventSubRevocation.self, forKey: .payload))
    }
  }

  internal struct Metadata: Decodable {
    let id: String
    let type: MessageType
    let timestamp: Date

    let subscriptionType: SubscriptionType?

    enum CodingKeys: String, CodingKey {
      case id = "messageId"
      case type = "messageType"
      case timestamp = "messageTimestamp"

      case subscriptionType = "subscriptionType"
    }

    enum MessageType: String, Decodable {
      case welcome = "session_welcome"
      case keepalive = "session_keepalive"
      case notification = "notification"
      case reconnect = "session_reconnect"
      case revocation = "revocation"
    }
  }

  // TODO: use this enum for the EventSubSubscription initializers
  internal enum SubscriptionType: String, Decodable {
    case channelFollow = "channel.follow"
    case channelChatClear = "channel.chat.clear"
    case channelChatMessage = "channel.chat.message"
  }
}
