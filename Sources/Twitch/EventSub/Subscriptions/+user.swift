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
  public static func userUpdate(userID: String)
    -> EventSubSubscription<UserUpdateEvent>
  {
    .init(
      type: "user.update", version: "1",
      condition: [
        "user_id": userID
      ])
  }
}
