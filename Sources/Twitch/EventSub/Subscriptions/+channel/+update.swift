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
  public static func channelUpdate(broadcasterID: String)
    -> EventSubSubscription<ChannelUpdateEvent>
  {
    .init(
      type: "channel.update", version: "2",
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }
}
