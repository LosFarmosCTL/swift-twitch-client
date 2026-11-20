import Foundation

/// A typed EventSub event paired with its Twitch delivery envelope metadata.
///
/// Delivered by ``TwitchClient/eventStream(for:bufferingPolicy:)``,
/// ``TwitchClient/eventListener(for:callback:)``, and ``TwitchClient/eventPublisher(for:)``.
///
/// - SeeAlso: <doc:EventSub>, ``EventSubSubscription``, ``Event``
public struct EventSubNotification<Payload: Sendable>: Sendable {
  /// The decoded event-specific payload.
  public let event: Payload
  /// Twitch's unique identifier for this notification message envelope.
  ///
  /// Useful for deduplication or correlating logs across reconnects.
  public let messageID: String
  /// The timestamp Twitch recorded when sending the notification.
  public let sentAt: Date
  /// The ID of the Twitch EventSub subscription that produced this notification.
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
