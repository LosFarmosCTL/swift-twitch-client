import Foundation

internal struct EventSubMessage: Decodable {
  let metadata: Metadata
  let payload: EventSubPayload

  enum CodingKeys: String, CodingKey {
    case metadata, payload
  }

  init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    metadata = try container.decode(Metadata.self, forKey: .metadata)

    switch metadata.messageType {
    case .welcome:
      self.payload = .welcome(
        try container.decode(EventSubWelcome.self, forKey: .payload))
    case .keepalive:
      self.payload = .keepalive
    case .notification:
      let notification = try container.nestedContainer(
        keyedBy: NotificationKeys.self, forKey: .payload)
      let subscription = try notification.decode(Subscription.self, forKey: .subscription)
      guard metadata.subscriptionType == subscription.type,
        metadata.subscriptionVersion == subscription.version
      else {
        throw DecodingError.dataCorruptedError(
          forKey: .subscription, in: notification,
          debugDescription: "EventSub subscription type or version differs from the metadata.")
      }
      self.payload = .notification(subscription)
    case .reconnect:
      self.payload = .reconnect(
        try container.decode(EventSubReconnect.self, forKey: .payload))
    case .revocation:
      self.payload = .revocation(
        try container.decode(EventSubRevocation.self, forKey: .payload))
    }
  }

  private enum NotificationKeys: CodingKey { case subscription }

  struct Subscription: Decodable, Sendable {
    let id: String
    let type: String
    let version: String
    @EventSubCondition private(set) var condition: [String: String]
  }

  internal struct Metadata: Decodable {
    let messageID: String
    let messageType: MessageType
    let messageTimestamp: Date
    let subscriptionType: String?
    let subscriptionVersion: String?

    enum CodingKeys: String, CodingKey {
      case messageID = "messageId"
      case messageType, messageTimestamp, subscriptionType, subscriptionVersion
    }

    enum MessageType: String, Decodable {
      case welcome = "session_welcome"
      case keepalive = "session_keepalive"
      case notification = "notification"
      case reconnect = "session_reconnect"
      case revocation = "revocation"
    }
  }
}

/// Twitch can echo nullable condition parameters that the request omitted.
@propertyWrapper
struct EventSubCondition: Decodable, Sendable {
  var wrappedValue: [String: String]

  init(wrappedValue: [String: String]) {
    self.wrappedValue = wrappedValue
  }

  init(from decoder: any Decoder) throws {
    wrappedValue = try decoder.singleValueContainer().decode([String: String?].self)
      .compactMapValues { $0 }
  }
}
