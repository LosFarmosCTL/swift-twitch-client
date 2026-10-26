extension EventSubSubscription {
  /// Creates a subscription description for AutoMod message hold notifications.
  ///
  /// Requires `moderator:manage:automod`. With WebSockets, `moderatorID` must match the
  /// token’s user, who must be the broadcaster or a moderator of the channel.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#automodmessagehold-v2
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - moderatorID: The Twitch user ID of the moderator.
  ///   - version: The EventSub subscription schema version. Defaults to `"2"`.
  public static func autoModMessageHold(
    broadcasterID: String,
    moderatorID: String,
    version: String = "2"
  ) -> EventSubSubscription<AutoModMessageHoldEvent> {
    .init(
      type: EventType.autoModMessageHold.rawValue, version: version,
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
  /// https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#automodmessageupdate-v2
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - moderatorID: The Twitch user ID of the moderator.
  ///   - version: The EventSub subscription schema version. Defaults to `"2"`.
  public static func autoModMessageUpdate(
    broadcasterID: String,
    moderatorID: String,
    version: String = "2"
  ) -> EventSubSubscription<AutoModMessageUpdateEvent> {
    .init(
      type: EventType.autoModMessageUpdate.rawValue, version: version,
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
  /// https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#automodsettingsupdate
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - moderatorID: The Twitch user ID of the moderator.
  ///   - version: The EventSub subscription schema version. Defaults to `"1"`.
  public static func autoModSettingsUpdate(
    broadcasterID: String,
    moderatorID: String,
    version: String = "1"
  ) -> EventSubSubscription<AutoModSettingsUpdateEvent> {
    .init(
      type: EventType.autoModSettingsUpdate.rawValue, version: version,
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
  /// https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#automodtermsupdate
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - moderatorID: The Twitch user ID of the moderator.
  ///   - version: The EventSub subscription schema version. Defaults to `"1"`.
  public static func autoModTermsUpdate(
    broadcasterID: String,
    moderatorID: String,
    version: String = "1"
  ) -> EventSubSubscription<AutoModTermsUpdateEvent> {
    .init(
      type: EventType.autoModTermsUpdate.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID,
        "moderator_user_id": moderatorID,
      ])
  }
}
