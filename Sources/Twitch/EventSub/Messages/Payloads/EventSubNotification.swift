import Foundation

/// A typed event with the metadata Twitch supplied for its EventSub delivery.
public struct EventSubNotification<Payload: Sendable>: Sendable {
  /// The event-specific payload.
  public let event: Payload
  /// The ID of the EventSub notification envelope.
  public let messageID: String
  /// When Twitch sent the notification.
  public let sentAt: Date
  /// The Twitch subscription that produced the notification.
  public let subscriptionID: String
}

extension EventSubNotification where Payload == any Event {
  func typed<R: Event>(as _: R.Type) -> EventSubNotification<R>? {
    guard let event = event as? R else { return nil }
    return EventSubNotification<R>(
      event: event, messageID: messageID, sentAt: sentAt, subscriptionID: subscriptionID)
  }
}

internal struct EventSubNotificationFrame: Sendable {
  let subscription: EventSubMessage.Subscription
  let notification: EventSubNotification<any Event>

  enum CodingKeys: CodingKey {
    case subscription, event
  }

  init(from decoder: any Decoder, messageID: String, sentAt: Date) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    subscription = try container.decode(EventSubMessage.Subscription.self, forKey: .subscription)

    guard let type = EventType(rawValue: subscription.type) else {
      throw DecodingError.dataCorruptedError(
        forKey: .subscription, in: container,
        debugDescription: "Unsupported EventSub type: \(subscription.type)")
    }

    notification = EventSubNotification<any Event>(
      event: try container.decode(type.event, forKey: .event),
      messageID: messageID, sentAt: sentAt, subscriptionID: subscription.id)
  }
}
