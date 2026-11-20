/// A typed EventSub subscription description.
///
/// Use a static factory to select an event and its conditions. Pass the description to
/// a client’s event stream, listener, or publisher API to observe events.
///
/// The client receives events over WebSockets using its user access token, which must
/// include the scopes required by the selected event. Built-in factories pair a fixed
/// Twitch schema with its event model. Where multiple versions are supported, each
/// version has its own factory and model.
///
/// Transport-specific app-token and prior-grant rules apply when creating subscriptions
/// through Helix with webhook or conduit transport; see the linked Twitch reference on
/// each factory.
public struct EventSubSubscription<EventNotification: Event>: Sendable {
  let type: String
  let version: String
  let condition: [String: String]
}

extension EventSubSubscription {
  /// Creates a subscription for a Twitch event type and schema version not covered
  /// by the built-in factories. Use the default for Helix creation, or supply a
  /// model to decode the payload when observing notifications over WebSocket.
  ///
  /// - Parameters:
  ///   - type: The Twitch subscription type.
  ///   - version: The Twitch subscription schema version.
  ///   - condition: The subscription condition using Twitch's wire keys.
  ///   - decoding: The WebSocket payload model. Defaults to `VoidEvent`, which
  ///     ignores the payload.
  public static func custom(
    type: String, version: String, condition: [String: String],
    decoding _: EventNotification.Type = VoidEvent.self
  ) -> Self {
    .init(type: type, version: version, condition: condition)
  }
}
