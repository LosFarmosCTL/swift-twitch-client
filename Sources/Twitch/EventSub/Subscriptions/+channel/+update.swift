extension EventSubSubscription {
  /// Creates a subscription description for channel update notifications.
  ///
  /// No event-specific scope is required.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelupdate
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - version: The EventSub subscription schema version. Defaults to `"2"`.
  public static func channelUpdate(broadcasterID: String, version: String = "2")
    -> EventSubSubscription<ChannelUpdateEvent>
  {
    .init(
      type: EventType.channelUpdate.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }
}
