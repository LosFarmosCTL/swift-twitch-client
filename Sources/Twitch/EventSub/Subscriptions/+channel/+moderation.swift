extension EventSubSubscription {
  /// Creates a version 2 subscription description for channel moderation notifications.
  ///
  /// Requires one scope from each pair: `moderator:read:blocked_terms` /
  /// `moderator:manage:blocked_terms`, `moderator:read:chat_settings` /
  /// `moderator:manage:chat_settings`, `moderator:read:unban_requests` /
  /// `moderator:manage:unban_requests`, `moderator:read:banned_users` /
  /// `moderator:manage:banned_users`, and `moderator:read:chat_messages` /
  /// `moderator:manage:chat_messages`. Also requires `moderator:read:warnings`
  /// or `moderator:manage:warnings`, plus `moderator:read:moderators`
  /// and `moderator:read:vips`. With WebSockets, `moderatorID` must match the token’s
  /// user, who must be the broadcaster or a moderator of the channel.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/eventsub/reference/channel-moderation/#channel-moderate-v2
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - moderatorID: The Twitch user ID of the moderator.
  public static func channelModerate(
    broadcasterID: String, moderatorID: String
  ) -> EventSubSubscription<ChannelModerateEvent> {
    .init(
      type: "channel.moderate", version: "2",
      condition: [
        "broadcaster_user_id": broadcasterID,
        "moderator_user_id": moderatorID,
      ])
  }

  /// Creates a subscription description for channel ban notifications.
  ///
  /// Requires `channel:moderate`. The broadcaster must grant the required scope; with
  /// WebSockets, use that broadcaster’s user token.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/eventsub/reference/channel-moderation/#channel-ban
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  public static func channelBan(broadcasterID: String)
    -> EventSubSubscription<ChannelBanEvent>
  {
    .init(
      type: "channel.ban", version: "1",
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }

  /// Creates a subscription description for channel unban notifications.
  ///
  /// Requires `channel:moderate`. The broadcaster must grant the required scope; with
  /// WebSockets, use that broadcaster’s user token.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/eventsub/reference/channel-moderation/#channel-unban
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  public static func channelUnban(broadcasterID: String)
    -> EventSubSubscription<ChannelUnbanEvent>
  {
    .init(
      type: "channel.unban", version: "1",
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }

  /// Creates a subscription description for channel moderator add notifications.
  ///
  /// Requires `moderation:read`. The broadcaster must grant the required scope; with
  /// WebSockets, use that broadcaster’s user token.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/eventsub/reference/channel-moderation/#channel-moderator-add
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  public static func channelModeratorAdd(broadcasterID: String)
    -> EventSubSubscription<ChannelModeratorAddEvent>
  {
    .init(
      type: "channel.moderator.add", version: "1",
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }

  /// Creates a subscription description for channel moderator remove notifications.
  ///
  /// Requires `moderation:read`. The broadcaster must grant the required scope; with
  /// WebSockets, use that broadcaster’s user token.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/eventsub/reference/channel-moderation/#channel-moderator-remove
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  public static func channelModeratorRemove(broadcasterID: String)
    -> EventSubSubscription<ChannelModeratorRemoveEvent>
  {
    .init(
      type: "channel.moderator.remove", version: "1",
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }

  /// Creates a subscription description for channel unban request create notifications.
  ///
  /// Requires `moderator:read:unban_requests` or `moderator:manage:unban_requests`. With
  /// WebSockets, `moderatorID` must match the token’s user, who must be the broadcaster
  /// or a moderator of the channel.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/eventsub/reference/channel-moderation/#channel-unban-request-create
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - moderatorID: The Twitch user ID of the moderator.
  public static func channelUnbanRequestCreate(
    broadcasterID: String, moderatorID: String
  ) -> EventSubSubscription<ChannelUnbanRequestCreateEvent> {
    .init(
      type: "channel.unban_request.create", version: "1",
      condition: [
        "broadcaster_user_id": broadcasterID,
        "moderator_user_id": moderatorID,
      ])
  }

  /// Creates a subscription description for channel unban request resolve notifications.
  ///
  /// Requires `moderator:read:unban_requests` or `moderator:manage:unban_requests`. With
  /// WebSockets, `moderatorID` must match the token’s user, who must be the broadcaster
  /// or a moderator of the channel.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/eventsub/reference/channel-moderation/#channel-unban-request-resolve
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - moderatorID: The Twitch user ID of the moderator.
  public static func channelUnbanRequestResolve(
    broadcasterID: String, moderatorID: String
  ) -> EventSubSubscription<ChannelUnbanRequestResolveEvent> {
    .init(
      type: "channel.unban_request.resolve", version: "1",
      condition: [
        "broadcaster_user_id": broadcasterID,
        "moderator_user_id": moderatorID,
      ])
  }

  /// Creates a subscription description for channel warning acknowledge notifications.
  ///
  /// Requires `moderator:read:warnings` or `moderator:manage:warnings`. With WebSockets,
  /// `moderatorID` must match the token’s user, who must be the broadcaster or a
  /// moderator of the channel.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/eventsub/reference/channel-moderation/#channel-warning-acknowledge
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - moderatorID: The Twitch user ID of the moderator.
  public static func channelWarningAcknowledge(
    broadcasterID: String, moderatorID: String
  ) -> EventSubSubscription<ChannelWarningAcknowledgeEvent> {
    .init(
      type: "channel.warning.acknowledge", version: "1",
      condition: [
        "broadcaster_user_id": broadcasterID,
        "moderator_user_id": moderatorID,
      ])
  }

  /// Creates a subscription description for channel warning send notifications.
  ///
  /// Requires `moderator:read:warnings` or `moderator:manage:warnings`. With WebSockets,
  /// `moderatorID` must match the token’s user, who must be the broadcaster or a
  /// moderator of the channel.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/eventsub/reference/channel-moderation/#channel-warning-send
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - moderatorID: The Twitch user ID of the moderator.
  public static func channelWarningSend(
    broadcasterID: String, moderatorID: String
  ) -> EventSubSubscription<ChannelWarningSendEvent> {
    .init(
      type: "channel.warning.send", version: "1",
      condition: [
        "broadcaster_user_id": broadcasterID,
        "moderator_user_id": moderatorID,
      ])
  }

  /// Creates a subscription description for channel suspicious user message
  /// notifications.
  ///
  /// Requires `moderator:read:suspicious_users`. With WebSockets, `moderatorID` must
  /// match the token’s user, who must be the broadcaster or a moderator of the channel.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/eventsub/reference/channel-moderation/#channel-suspicious-user-message
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - moderatorID: The Twitch user ID of the moderator.
  public static func channelSuspiciousUserMessage(
    broadcasterID: String, moderatorID: String
  ) -> EventSubSubscription<ChannelSuspiciousUserMessageEvent> {
    .init(
      type: "channel.suspicious_user.message", version: "1",
      condition: [
        "moderator_user_id": moderatorID,
        "broadcaster_user_id": broadcasterID,
      ])
  }

  /// Creates a subscription description for channel suspicious user update notifications.
  ///
  /// Requires `moderator:read:suspicious_users`. With WebSockets, `moderatorID` must
  /// match the token’s user, who must be the broadcaster or a moderator of the channel.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/eventsub/reference/channel-moderation/#channel-suspicious-user-update
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - moderatorID: The Twitch user ID of the moderator.
  public static func channelSuspiciousUserUpdate(
    broadcasterID: String, moderatorID: String
  ) -> EventSubSubscription<ChannelSuspiciousUserUpdateEvent> {
    .init(
      type: "channel.suspicious_user.update", version: "1",
      condition: [
        "moderator_user_id": moderatorID,
        "broadcaster_user_id": broadcasterID,
      ])
  }

  /// Creates a subscription description for channel shield mode begin notifications.
  ///
  /// Requires `moderator:read:shield_mode` or `moderator:manage:shield_mode`. With
  /// WebSockets, `moderatorID` must match the token’s user, who must be the broadcaster
  /// or a moderator of the channel.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/eventsub/reference/channel-moderation/#channel-shield-mode-begin
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - moderatorID: The Twitch user ID of the moderator.
  public static func channelShieldModeBegin(
    broadcasterID: String, moderatorID: String
  ) -> EventSubSubscription<ChannelShieldModeBeginEvent> {
    .init(
      type: "channel.shield_mode.begin", version: "1",
      condition: [
        "broadcaster_user_id": broadcasterID,
        "moderator_user_id": moderatorID,
      ])
  }

  /// Creates a subscription description for channel shield mode end notifications.
  ///
  /// Requires `moderator:read:shield_mode` or `moderator:manage:shield_mode`. With
  /// WebSockets, `moderatorID` must match the token’s user, who must be the broadcaster
  /// or a moderator of the channel.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/eventsub/reference/channel-moderation/#channel-shield-mode-end
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - moderatorID: The Twitch user ID of the moderator.
  public static func channelShieldModeEnd(
    broadcasterID: String, moderatorID: String
  ) -> EventSubSubscription<ChannelShieldModeEndEvent> {
    .init(
      type: "channel.shield_mode.end", version: "1",
      condition: [
        "broadcaster_user_id": broadcasterID,
        "moderator_user_id": moderatorID,
      ])
  }
}
