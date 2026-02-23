import Foundation

internal struct EventSubNotification: Decodable {
  let subscription: Subscription
  let event: Event

  enum CodingKeys: CodingKey {
    case subscription, event
  }

  internal init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    self.subscription = try container.decode(Subscription.self, forKey: .subscription)
    self.event = try container.decode(self.subscription.type.event, forKey: .event)
  }

  struct Subscription: Decodable {
    let id: String
    let type: EventType
    let version: String
  }
}
