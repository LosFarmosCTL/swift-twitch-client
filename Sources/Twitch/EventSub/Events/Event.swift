/// A decodable, sendable notification payload delivered by Twitch EventSub.
///
/// Conform your own `Decodable & Sendable` types to `Event` when subscribing to custom or
/// newly released EventSub topics with
/// ``EventSubSubscription/custom(type:version:condition:decoding:)``.
///
/// - SeeAlso: <doc:EventSub>, ``EventSubNotification``, ``VoidEvent``
public protocol Event: Decodable, Sendable {}

/// An ``Event`` placeholder that ignores the notification payload during decoding.
///
/// Used as the default payload type for
/// ``EventSubSubscription/custom(type:version:condition:decoding:)`` when you only need
/// the notification metadata or are registering a non-WebSocket subscription through Helix.
public struct VoidEvent: Event {
  /// Decodes a `VoidEvent`, ignoring all payload fields.
  public init(from _: any Decoder) throws {}
}
