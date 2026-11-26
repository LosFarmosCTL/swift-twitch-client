extension EventSubSubscription {
  /// Creates a subscription description for user update notifications.
  ///
  /// Display name, description, and authorized email changes trigger this event.
  /// Email-only changes require `user:read:email` from that user. For WebSockets,
  /// the access token must also belong to that user to receive email data.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/eventsub/reference/user/#user-update
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
