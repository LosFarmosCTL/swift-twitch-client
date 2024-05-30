import Foundation

internal struct EventSubNotification: Decodable {
  let subscription: Subscription
  let event: Event

  enum CodingKeys: CodingKey {
    case subscription
    case event
  }

  internal init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    self.subscription = try container.decode(Subscription.self, forKey: .subscription)

    self.event =
      switch subscription.type {
      case .channelFollow: try container.decode(ChannelFollowEvent.self, forKey: .event)
      case .chatMessage: try container.decode(ChatMessageEvent.self, forKey: .event)
      }
  }

  struct Subscription: Decodable {
    let id: String
    let type: EventType
    let version: String
  }

  // TODO: wayyy to many of these subscription string enums
  enum EventType: String, Decodable {
    case channelFollow = "channel.follow"
    case chatMessage = "channel.chat.message"
  }
}

public protocol Event: Decodable {}
