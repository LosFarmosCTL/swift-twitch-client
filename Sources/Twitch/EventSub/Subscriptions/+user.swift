extension EventSubSubscription {
  /// Creates a subscription description for user update notifications.
  ///
  /// No event-specific scope is required. Email is included only when authorized with
  /// `user:read:email`.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#userupdate
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - userID: The Twitch user ID.
  ///   - version: The EventSub subscription schema version. Defaults to `"1"`.
  public static func userUpdate(userID: String, version: String = "1")
    -> EventSubSubscription<UserUpdateEvent>
  {
    .init(
      type: EventType.userUpdate.rawValue, version: version,
      condition: [
        "user_id": userID
      ])
  }
}
