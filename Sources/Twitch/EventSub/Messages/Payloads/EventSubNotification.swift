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
  let connectionID: UUID
  let subscription: EventSubMessage.Subscription
  let messageID: String
  let sentAt: Date
  // Keep the original frame for decoding after the subscription ID is confirmed.
  let data: Data

  func decode<E: Event>(
    as _: E.Type, using decoder: JSONDecoder
  ) throws -> EventSubNotification<any Event> {
    let event = try decoder.decode(Envelope<E>.self, from: data).payload.event
    return EventSubNotification<any Event>(
      event: event, messageID: messageID, sentAt: sentAt, subscriptionID: subscription.id)
  }

  private struct Envelope<E: Event>: Decodable {
    struct Payload: Decodable {
      let event: E
    }

    let payload: Payload
  }
}
