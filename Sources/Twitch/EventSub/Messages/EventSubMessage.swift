import Foundation

internal struct EventSubMessage: Decodable {
  let payload: EventSubPayload

  enum CodingKeys: String, CodingKey {
    case metadata, payload
  }

  init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    let metadata = try container.decode(Metadata.self, forKey: .metadata)

    switch metadata.messageType {
    case .welcome:
      self.payload = .welcome(
        try container.decode(EventSubWelcome.self, forKey: .payload))
    case .keepalive:
      self.payload = .keepalive
    case .notification:
      self.payload = .notification(
        try EventSubNotificationFrame(
          from: container.superDecoder(forKey: .payload),
          messageID: metadata.messageID, sentAt: metadata.messageTimestamp))
    case .reconnect:
      self.payload = .reconnect(
        try container.decode(EventSubReconnect.self, forKey: .payload))
    case .revocation:
      self.payload = .revocation(
        try container.decode(EventSubRevocation.self, forKey: .payload))
    }
  }

  struct Subscription: Decodable, Sendable {
    let id: String
    let type: String
    let version: String
    let condition: [String: String]

    enum CodingKeys: CodingKey { case id, type, version, condition }

    init(from decoder: any Decoder) throws {
      let fields = try decoder.container(keyedBy: CodingKeys.self)

      id = try fields.decode(String.self, forKey: .id)
      type = try fields.decode(String.self, forKey: .type)
      version = try fields.decode(String.self, forKey: .version)

      // Twitch can echo a nullable condition parameter that the request omitted.
      condition = try fields.decode([String: String?].self, forKey: .condition).compactMapValues {
        $0
      }
    }
  }

  internal struct Metadata: Decodable {
    let messageID: String
    let messageType: MessageType
    let messageTimestamp: Date

    enum CodingKeys: String, CodingKey {
      case messageID = "messageId"
      case messageType, messageTimestamp
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
