extension EventSubSubscription {
  /// Creates a subscription description for stream online notifications.
  ///
  /// No event-specific scope is required.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#streamonline
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - version: The EventSub subscription schema version. Defaults to `"1"`.
  public static func streamOnline(broadcasterID: String, version: String = "1")
    -> EventSubSubscription<StreamOnlineEvent>
  {
    .init(
      type: EventType.streamOnline.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }

  /// Creates a subscription description for stream offline notifications.
  ///
  /// No event-specific scope is required.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#streamoffline
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - version: The EventSub subscription schema version. Defaults to `"1"`.
  public static func streamOffline(broadcasterID: String, version: String = "1")
    -> EventSubSubscription<StreamOfflineEvent>
  {
    .init(
      type: EventType.streamOffline.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }
}
