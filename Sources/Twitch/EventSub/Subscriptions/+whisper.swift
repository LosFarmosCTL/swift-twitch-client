extension EventSubSubscription {
  /// Creates a subscription description for user whisper message notifications.
  ///
  /// Requires `user:read:whispers` or `user:manage:whispers`. With WebSockets, `userID`
  /// must match the token’s user.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#userwhispermessage
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - userID: The Twitch user ID.
  public static func userWhisperMessage(userID: String)
    -> EventSubSubscription<UserWhisperMessageEvent>
  {
    .init(
      type: "user.whisper.message", version: "1",
      condition: [
        "user_id": userID
      ])
  }
}
