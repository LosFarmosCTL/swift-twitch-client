/// A typed description of a Twitch EventSub subscription topic and condition.
///
/// Construct a subscription with one of the static factory methods (such as
/// ``streamOnline(broadcasterID:)`` or ``channelFollow(broadcasterID:moderatorID:)``),
/// then pass it to ``TwitchClient/eventStream(for:bufferingPolicy:)``,
/// ``TwitchClient/eventListener(for:callback:)``, or ``TwitchClient/eventPublisher(for:)``.
/// Creating a subscription value performs no network I/O.
///
/// Direct WebSocket subscriptions require user OAuth credentials whose scopes satisfy the
/// selected topic. Built-in factories pair a fixed Twitch schema version with its typed
/// ``Event`` model; when Twitch publishes multiple schema versions, each version has its
/// own factory and model. For topics not covered by a built-in factory, use
/// ``custom(type:version:condition:decoding:)``.
///
/// - Note: To create webhook or conduit subscriptions with an app access token, call
///   ``HelixEndpoint/createEventSubSubscription(using:for:isBatchingEnabled:)`` through
///   Helix directly.
/// - SeeAlso: <doc:EventSub>, ``Event``, ``EventSubNotification``
public struct EventSubSubscription<EventNotification: Event>: Sendable {
  let type: String
  let version: String
  let condition: [String: String]
}

extension EventSubSubscription {
  /// Creates a subscription for a Twitch EventSub topic or version without a built-in factory.
  ///
  /// Supply a custom `Event`-conforming type in `decoding` to decode notification
  /// payloads over WebSocket, or leave the default ``VoidEvent`` when creating a raw
  /// subscription through Helix or ignoring the payload.
  ///
  /// - Parameters:
  ///   - type: The Twitch EventSub subscription type string (for example, `"stream.online"`).
  ///   - version: The Twitch EventSub schema version string (for example, `"1"`).
  ///   - condition: The condition dictionary using Twitch's exact wire keys (for example,
  ///     `["broadcaster_user_id": "1234"]`).
  ///   - decoding: The ``Event`` type used to decode incoming notification payloads.
  ///     Defaults to ``VoidEvent``, which ignores payload contents.
  /// - Returns: A typed `EventSubSubscription` ready to pass to a client observation method
  ///   or ``HelixEndpoint/createEventSubSubscription(using:for:isBatchingEnabled:)``.
  public static func custom(
    type: String, version: String, condition: [String: String],
    decoding _: EventNotification.Type = VoidEvent.self
  ) -> Self {
    .init(type: type, version: version, condition: condition)
  }
}
