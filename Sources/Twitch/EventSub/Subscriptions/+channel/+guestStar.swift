extension EventSubSubscription {
  /// Creates a subscription description for channel guest star session begin
  /// notifications.
  ///
  /// Requires `channel:read:guest_star` or `channel:manage:guest_star` or
  /// `moderator:read:guest_star` or `moderator:manage:guest_star`. With WebSockets,
  /// `moderatorID` must match the token’s user, who must be the broadcaster or a
  /// moderator of the channel.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelguest_star_sessionbegin
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - moderatorID: The Twitch user ID of the moderator.
  ///   - version: The EventSub subscription schema version. Defaults to `"beta"`.
  public static func channelGuestStarSessionBegin(
    broadcasterID: String, moderatorID: String, version: String = "beta"
  ) -> EventSubSubscription<ChannelGuestStarSessionBeginEvent> {
    .init(
      type: EventType.channelGuestStarSessionBegin.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID,
        "moderator_user_id": moderatorID,
      ])
  }

  /// Creates a subscription description for channel guest star session end notifications.
  ///
  /// Requires `channel:read:guest_star` or `channel:manage:guest_star` or
  /// `moderator:read:guest_star` or `moderator:manage:guest_star`. With WebSockets,
  /// `moderatorID` must match the token’s user, who must be the broadcaster or a
  /// moderator of the channel.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelguest_star_sessionend
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - moderatorID: The Twitch user ID of the moderator.
  ///   - version: The EventSub subscription schema version. Defaults to `"beta"`.
  public static func channelGuestStarSessionEnd(
    broadcasterID: String, moderatorID: String, version: String = "beta"
  ) -> EventSubSubscription<ChannelGuestStarSessionEndEvent> {
    .init(
      type: EventType.channelGuestStarSessionEnd.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID,
        "moderator_user_id": moderatorID,
      ])
  }

  /// Creates a subscription description for channel guest star guest update
  /// notifications.
  ///
  /// Requires `channel:read:guest_star` or `channel:manage:guest_star` or
  /// `moderator:read:guest_star` or `moderator:manage:guest_star`. With WebSockets,
  /// `moderatorID` must match the token’s user, who must be the broadcaster or a
  /// moderator of the channel.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelguest_star_guestupdate
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - moderatorID: The Twitch user ID of the moderator.
  ///   - version: The EventSub subscription schema version. Defaults to `"beta"`.
  public static func channelGuestStarGuestUpdate(
    broadcasterID: String, moderatorID: String, version: String = "beta"
  ) -> EventSubSubscription<ChannelGuestStarGuestUpdateEvent> {
    .init(
      type: EventType.channelGuestStarGuestUpdate.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID,
        "moderator_user_id": moderatorID,
      ])
  }

  /// Creates a subscription description for channel guest star settings update
  /// notifications.
  ///
  /// Requires `channel:read:guest_star` or `channel:manage:guest_star` or
  /// `moderator:read:guest_star` or `moderator:manage:guest_star`. With WebSockets,
  /// `moderatorID` must match the token’s user, who must be the broadcaster or a
  /// moderator of the channel.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelguest_star_settingsupdate
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - moderatorID: The Twitch user ID of the moderator.
  ///   - version: The EventSub subscription schema version. Defaults to `"beta"`.
  ///
  /// - Returns: A subscription that decodes `ChannelGuestStarSettingsUpdateEvent`
  ///   payloads.
  public static func channelGuestStarSettingsUpdate(
    broadcasterID: String, moderatorID: String, version: String = "beta"
  ) -> EventSubSubscription<ChannelGuestStarSettingsUpdateEvent> {
    .init(
      type: EventType.channelGuestStarSettingsUpdate.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID,
        "moderator_user_id": moderatorID,
      ])
  }
}
