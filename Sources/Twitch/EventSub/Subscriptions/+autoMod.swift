extension EventSubSubscription {
  /// Creates a subscription description for AutoMod message hold notifications.
  /// Messages matching the channel’s private blocked terms do not trigger this event.
  ///
  /// Requires `moderator:manage:automod`. With WebSockets, `moderatorID` must match the
  /// token’s user, who must be the broadcaster or a moderator of the channel.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/eventsub/reference/automod/#automod-message-hold-v2
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - moderatorID: The Twitch user ID of the moderator.
  public static func autoModMessageHold(
    broadcasterID: String,
    moderatorID: String
  ) -> EventSubSubscription<AutoModMessageHoldEvent> {
    .init(
      type: "automod.message.hold", version: "2",
      condition: [
        "broadcaster_user_id": broadcasterID,
        "moderator_user_id": moderatorID,
      ])
  }

  /// Creates a subscription description for AutoMod message update notifications.
  ///
  /// Requires `moderator:manage:automod`. With WebSockets, `moderatorID` must match the
  /// token’s user, who must be the broadcaster or a moderator of the channel.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/eventsub/reference/automod/#automod-message-update-v2
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - moderatorID: The Twitch user ID of the moderator.
  public static func autoModMessageUpdate(
    broadcasterID: String,
    moderatorID: String
  ) -> EventSubSubscription<AutoModMessageUpdateEvent> {
    .init(
      type: "automod.message.update", version: "2",
      condition: [
        "broadcaster_user_id": broadcasterID,
        "moderator_user_id": moderatorID,
      ])
  }

  /// Creates a subscription description for AutoMod settings update notifications.
  ///
  /// Requires `moderator:read:automod_settings`. With WebSockets, `moderatorID` must
  /// match the token’s user, who must be the broadcaster or a moderator of the channel.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/eventsub/reference/automod/#automod-settings-update
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - moderatorID: The Twitch user ID of the moderator.
  public static func autoModSettingsUpdate(
    broadcasterID: String,
    moderatorID: String
  ) -> EventSubSubscription<AutoModSettingsUpdateEvent> {
    .init(
      type: "automod.settings.update", version: "1",
      condition: [
        "broadcaster_user_id": broadcasterID,
        "moderator_user_id": moderatorID,
      ])
  }

  /// Creates a subscription description for AutoMod terms update notifications.
  ///
  /// Requires `moderator:manage:automod`. With WebSockets, `moderatorID` must match the
  /// token’s user, who must be the broadcaster or a moderator of the channel.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/eventsub/reference/automod/#automod-terms-update
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - moderatorID: The Twitch user ID of the moderator.
  public static func autoModTermsUpdate(
    broadcasterID: String,
    moderatorID: String
  ) -> EventSubSubscription<AutoModTermsUpdateEvent> {
    .init(
      type: "automod.terms.update", version: "1",
      condition: [
        "broadcaster_user_id": broadcasterID,
        "moderator_user_id": moderatorID,
      ])
  }
}
