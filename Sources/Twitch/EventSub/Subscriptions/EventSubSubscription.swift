/// A typed EventSub subscription description.
///
/// Use a static factory to select an event and its conditions. Pass the description to
/// a client’s event stream, listener, or publisher API to observe events.
///
/// The client receives events over WebSockets using its user access token, which must
/// include the scopes required by the selected event. Each factory pairs a fixed
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
