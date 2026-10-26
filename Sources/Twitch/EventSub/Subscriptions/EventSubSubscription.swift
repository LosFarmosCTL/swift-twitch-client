/// A typed EventSub subscription description.
///
/// Use a static factory to select an event and its conditions. Constructing a description
/// does not subscribe to Twitch. Pass it to a client’s event stream, listener, or
/// publisher API to create the subscription.
///
/// The client receives events over WebSockets using its user access token, which must
/// include the scopes required by the selected event. A `version` parameter selects
/// Twitch’s event schema, not a library version; overriding it does not change this
/// type’s decoder.
///
/// Transport-specific app-token and prior-grant rules apply when creating subscriptions
/// through Helix with webhook or conduit transport; see the linked Twitch reference on
/// each factory.
public struct EventSubSubscription<EventNotification: Event>: Sendable {
  let type: String
  let version: String
  let condition: [String: String]
}
