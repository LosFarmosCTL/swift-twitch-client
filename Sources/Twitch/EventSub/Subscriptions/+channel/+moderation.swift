extension EventSubSubscription {
  /// Creates a subscription description for channel moderate notifications.
  ///
  /// Requires one scope from each pair: `moderator:read:blocked_terms` /
  /// `moderator:manage:blocked_terms`, `moderator:read:chat_settings` /
  /// `moderator:manage:chat_settings`, `moderator:read:unban_requests` /
  /// `moderator:manage:unban_requests`, `moderator:read:banned_users` /
  /// `moderator:manage:banned_users`, and `moderator:read:chat_messages` /
  /// `moderator:manage:chat_messages`. Version 2 also requires `moderator:read:warnings`
  /// or `moderator:manage:warnings`. Both versions require `moderator:read:moderators`
  /// and `moderator:read:vips`. With WebSockets, `moderatorID` must match the token’s
  /// user, who must be the broadcaster or a moderator of the channel.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelmoderate-v2
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - moderatorID: The Twitch user ID of the moderator.
  ///   - version: The EventSub subscription schema version. Defaults to `"2"`.
  public static func channelModerate(
    broadcasterID: String, moderatorID: String, version: String = "2"
  ) -> EventSubSubscription<ChannelModerateEvent> {
    .init(
      type: EventType.channelModerate.rawValue, version: version,
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
  /// https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelban
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - version: The EventSub subscription schema version. Defaults to `"1"`.
  public static func channelBan(broadcasterID: String, version: String = "1")
    -> EventSubSubscription<ChannelBanEvent>
  {
    .init(
      type: EventType.channelBan.rawValue, version: version,
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
  /// https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelunban
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - version: The EventSub subscription schema version. Defaults to `"1"`.
  public static func channelUnban(broadcasterID: String, version: String = "1")
    -> EventSubSubscription<ChannelUnbanEvent>
  {
    .init(
      type: EventType.channelUnban.rawValue, version: version,
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
  /// https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelmoderatoradd
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - version: The EventSub subscription schema version. Defaults to `"1"`.
  public static func channelModeratorAdd(broadcasterID: String, version: String = "1")
    -> EventSubSubscription<ChannelModeratorAddEvent>
  {
    .init(
      type: EventType.channelModeratorAdd.rawValue, version: version,
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
  /// https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelmoderatorremove
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - version: The EventSub subscription schema version. Defaults to `"1"`.
  public static func channelModeratorRemove(broadcasterID: String, version: String = "1")
    -> EventSubSubscription<ChannelModeratorRemoveEvent>
  {
    .init(
      type: EventType.channelModeratorRemove.rawValue, version: version,
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
  /// https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelunban_requestcreate
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - moderatorID: The Twitch user ID of the moderator.
  ///   - version: The EventSub subscription schema version. Defaults to `"1"`.
  public static func channelUnbanRequestCreate(
    broadcasterID: String, moderatorID: String, version: String = "1"
  ) -> EventSubSubscription<ChannelUnbanRequestCreateEvent> {
    .init(
      type: EventType.channelUnbanRequestCreate.rawValue, version: version,
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
  /// https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelunban_requestresolve
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - moderatorID: The Twitch user ID of the moderator.
  ///   - version: The EventSub subscription schema version. Defaults to `"1"`.
  public static func channelUnbanRequestResolve(
    broadcasterID: String, moderatorID: String, version: String = "1"
  ) -> EventSubSubscription<ChannelUnbanRequestResolveEvent> {
    .init(
      type: EventType.channelUnbanRequestResolve.rawValue, version: version,
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
  /// https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelwarningacknowledge
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - moderatorID: The Twitch user ID of the moderator.
  ///   - version: The EventSub subscription schema version. Defaults to `"1"`.
  public static func channelWarningAcknowledge(
    broadcasterID: String, moderatorID: String, version: String = "1"
  ) -> EventSubSubscription<ChannelWarningAcknowledgeEvent> {
    .init(
      type: EventType.channelWarningAcknowledge.rawValue, version: version,
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
  /// https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelwarningsend
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - moderatorID: The Twitch user ID of the moderator.
  ///   - version: The EventSub subscription schema version. Defaults to `"1"`.
  public static func channelWarningSend(
    broadcasterID: String, moderatorID: String, version: String = "1"
  ) -> EventSubSubscription<ChannelWarningSendEvent> {
    .init(
      type: EventType.channelWarningSend.rawValue, version: version,
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
  /// https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelsuspicious_usermessage
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - moderatorID: The Twitch user ID of the moderator.
  ///   - version: The EventSub subscription schema version. Defaults to `"1"`.
  public static func channelSuspiciousUserMessage(
    broadcasterID: String, moderatorID: String, version: String = "1"
  ) -> EventSubSubscription<ChannelSuspiciousUserMessageEvent> {
    .init(
      type: EventType.channelSuspiciousUserMessage.rawValue, version: version,
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
  /// https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelsuspicious_userupdate
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - moderatorID: The Twitch user ID of the moderator.
  ///   - version: The EventSub subscription schema version. Defaults to `"1"`.
  public static func channelSuspiciousUserUpdate(
    broadcasterID: String, moderatorID: String, version: String = "1"
  ) -> EventSubSubscription<ChannelSuspiciousUserUpdateEvent> {
    .init(
      type: EventType.channelSuspiciousUserUpdate.rawValue, version: version,
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
  /// https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelshield_modebegin
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - moderatorID: The Twitch user ID of the moderator.
  ///   - version: The EventSub subscription schema version. Defaults to `"1"`.
  public static func channelShieldModeBegin(
    broadcasterID: String, moderatorID: String, version: String = "1"
  ) -> EventSubSubscription<ChannelShieldModeBeginEvent> {
    .init(
      type: EventType.channelShieldModeBegin.rawValue, version: version,
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
  /// https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelshield_modeend
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - moderatorID: The Twitch user ID of the moderator.
  ///   - version: The EventSub subscription schema version. Defaults to `"1"`.
  public static func channelShieldModeEnd(
    broadcasterID: String, moderatorID: String, version: String = "1"
  ) -> EventSubSubscription<ChannelShieldModeEndEvent> {
    .init(
      type: EventType.channelShieldModeEnd.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID,
        "moderator_user_id": moderatorID,
      ])
  }
}
