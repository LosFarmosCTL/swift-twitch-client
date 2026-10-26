import Foundation

internal struct EventSubMessage: Decodable {
  let id: String
  let timestamp: Date

  let payload: EventSubPayload

  enum CodingKeys: String, CodingKey {
    case metadata, payload
  }

  init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    let metadata = try container.decode(Metadata.self, forKey: .metadata)

    self.id = metadata.messageID
    self.timestamp = metadata.messageTimestamp

    // depending on the type of message, we need to decode a different payload
    switch metadata.messageType {
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
