extension EventSubSubscription {
  /// Creates a subscription description for channel update notifications.
  ///
  /// Changes to the category, title, content classification labels, or broadcast language
  /// trigger this event. Label changes can generate a separate notification.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/eventsub/reference/channel/#channel-update
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
