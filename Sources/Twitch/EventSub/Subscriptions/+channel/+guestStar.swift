extension EventSubSubscription {
  /// Creates a subscription description for channel guest star session begin
  /// notifications.
  ///
  /// Requires `channel:read:guest_star` or `channel:manage:guest_star` or
  /// `moderator:read:guest_star` or `moderator:manage:guest_star`. With WebSockets,
  /// `moderatorID` must match the token’s user, who must be the broadcaster or a
  /// Guest Star moderator of the channel.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/eventsub/reference/guest-star/#channel-guest-star-session-begin
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - moderatorID: The Twitch user ID of the broadcaster or one of their Guest Star moderators.
  ///
  /// - Important: Uses Twitch’s beta Guest Star schema. Twitch may change the schema
  ///   and its behavior without notice.
  public static func channelGuestStarSessionBegin(
    broadcasterID: String, moderatorID: String
  ) -> EventSubSubscription<ChannelGuestStarSessionBeginEvent> {
    .init(
      type: "channel.guest_star_session.begin", version: "beta",
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
  /// Guest Star moderator of the channel.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/eventsub/reference/guest-star/#channel-guest-star-session-end
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - moderatorID: The Twitch user ID of the broadcaster or one of their Guest Star moderators.
  ///
  /// - Important: Uses Twitch’s beta Guest Star schema. Twitch may change the schema
  ///   and its behavior without notice.
  public static func channelGuestStarSessionEnd(
    broadcasterID: String, moderatorID: String
  ) -> EventSubSubscription<ChannelGuestStarSessionEndEvent> {
    .init(
      type: "channel.guest_star_session.end", version: "beta",
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
  /// Guest Star moderator of the channel.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/eventsub/reference/guest-star/#channel-guest-star-guest-update
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - moderatorID: The Twitch user ID of the broadcaster or one of their Guest Star moderators.
  ///
  /// - Important: Uses Twitch’s beta Guest Star schema. Twitch may change the schema
  ///   and its behavior without notice.
  public static func channelGuestStarGuestUpdate(
    broadcasterID: String, moderatorID: String
  ) -> EventSubSubscription<ChannelGuestStarGuestUpdateEvent> {
    .init(
      type: "channel.guest_star_guest.update", version: "beta",
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
  /// Guest Star moderator of the channel.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/eventsub/reference/guest-star/#channel-guest-star-settings-update
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - moderatorID: The Twitch user ID of the broadcaster or one of their Guest Star moderators.
  ///
  /// - Important: Uses Twitch’s beta Guest Star schema. Twitch may change the schema
  ///   and its behavior without notice.
  ///
  /// - Returns: A subscription that decodes `ChannelGuestStarSettingsUpdateEvent`
  ///   payloads.
  public static func channelGuestStarSettingsUpdate(
    broadcasterID: String, moderatorID: String
  ) -> EventSubSubscription<ChannelGuestStarSettingsUpdateEvent> {
    .init(
      type: "channel.guest_star_settings.update", version: "beta",
      condition: [
        "broadcaster_user_id": broadcasterID,
        "moderator_user_id": moderatorID,
      ])
  }
}
