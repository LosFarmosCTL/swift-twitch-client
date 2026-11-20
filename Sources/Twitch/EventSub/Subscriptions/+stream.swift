extension EventSubSubscription {
  /// Creates a subscription description for stream online notifications.
  ///
  /// No event-specific scope is required.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/eventsub/reference/stream/#stream-online
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  public static func streamOnline(broadcasterID: String)
    -> EventSubSubscription<StreamOnlineEvent>
  {
    .init(
      type: "stream.online", version: "1",
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }

  /// Creates a subscription description for stream offline notifications.
  ///
  /// No event-specific scope is required.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/eventsub/reference/stream/#stream-offline
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  public static func streamOffline(broadcasterID: String)
    -> EventSubSubscription<StreamOfflineEvent>
  {
    .init(
      type: "stream.offline", version: "1",
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }
}
