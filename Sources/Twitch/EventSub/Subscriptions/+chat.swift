extension EventSubSubscription {
  /// Creates a subscription description for channel chat clear notifications.
  ///
  /// Requires `user:read:chat`. With WebSockets, `userID` must match the token’s user.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelchatclear
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - userID: The Twitch user ID.
  ///   - version: The EventSub subscription schema version. Defaults to `"1"`.
  public static func channelChatClear(
    broadcasterID: String, userID: String, version: String = "1"
  ) -> EventSubSubscription<ChannelChatClearEvent> {
    .init(
      type: EventType.channelChatClear.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID,
        "user_id": userID,
      ])
  }

  /// Creates a subscription description for channel chat clear user messages
  /// notifications.
  ///
  /// Requires `user:read:chat`. With WebSockets, `userID` must match the token’s user.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelchatclear_user_messages
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - userID: The Twitch user ID.
  ///   - version: The EventSub subscription schema version. Defaults to `"1"`.
  public static func channelChatClearUserMessages(
    broadcasterID: String, userID: String, version: String = "1"
  ) -> EventSubSubscription<ChannelChatClearUserMessagesEvent> {
    .init(
      type: EventType.channelChatClearUserMessages.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID,
        "user_id": userID,
      ])
  }

  /// Creates a subscription description for channel chat message notifications.
  ///
  /// Requires `user:read:chat`. With WebSockets, `userID` must match the token’s user.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelchatmessage
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - userID: The Twitch user ID.
  ///   - version: The EventSub subscription schema version. Defaults to `"1"`.
  public static func channelChatMessage(
    broadcasterID: String, userID: String, version: String = "1"
  ) -> EventSubSubscription<ChannelChatMessageEvent> {
    .init(
      type: EventType.channelChatMessage.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID,
        "user_id": userID,
      ])
  }

  /// Creates a subscription description for channel chat message delete notifications.
  ///
  /// Requires `user:read:chat`. With WebSockets, `userID` must match the token’s user.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelchatmessage_delete
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - userID: The Twitch user ID.
  ///   - version: The EventSub subscription schema version. Defaults to `"1"`.
  public static func channelChatMessageDelete(
    broadcasterID: String, userID: String, version: String = "1"
  ) -> EventSubSubscription<ChannelChatMessageDeleteEvent> {
    .init(
      type: EventType.channelChatMessageDelete.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID,
        "user_id": userID,
      ])
  }

  /// Creates a subscription description for channel chat notification notifications.
  ///
  /// Requires `user:read:chat`. With WebSockets, `userID` must match the token’s user.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelchatnotification
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - userID: The Twitch user ID.
  ///   - version: The EventSub subscription schema version. Defaults to `"1"`.
  public static func channelChatNotification(
    broadcasterID: String, userID: String, version: String = "1"
  ) -> EventSubSubscription<ChannelChatNotificationEvent> {
    .init(
      type: EventType.channelChatNotification.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID,
        "user_id": userID,
      ])
  }

  /// Creates a subscription description for channel chat settings update notifications.
  ///
  /// Requires `user:read:chat`. With WebSockets, `userID` must match the token’s user.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelchat_settingsupdate
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - userID: The Twitch user ID.
  ///   - version: The EventSub subscription schema version. Defaults to `"1"`.
  public static func channelChatSettingsUpdate(
    broadcasterID: String, userID: String, version: String = "1"
  ) -> EventSubSubscription<ChannelChatSettingsUpdateEvent> {
    .init(
      type: EventType.channelChatSettingsUpdate.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID,
        "user_id": userID,
      ])
  }

  /// Creates a subscription description for channel chat user message hold notifications.
  ///
  /// Requires `user:read:chat`. With WebSockets, `userID` must match the token’s user.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelchatuser_message_hold
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - userID: The Twitch user ID.
  ///   - version: The EventSub subscription schema version. Defaults to `"1"`.
  public static func channelChatUserMessageHold(
    broadcasterID: String, userID: String, version: String = "1"
  ) -> EventSubSubscription<ChannelChatUserMessageHoldEvent> {
    .init(
      type: EventType.channelChatUserMessageHold.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID,
        "user_id": userID,
      ])
  }

  /// Creates a subscription description for channel chat user message update
  /// notifications.
  ///
  /// Requires `user:read:chat`. With WebSockets, `userID` must match the token’s user.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelchatuser_message_update
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - userID: The Twitch user ID.
  ///   - version: The EventSub subscription schema version. Defaults to `"1"`.
  public static func channelChatUserMessageUpdate(
    broadcasterID: String, userID: String, version: String = "1"
  ) -> EventSubSubscription<ChannelChatUserMessageUpdateEvent> {
    .init(
      type: EventType.channelChatUserMessageUpdate.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID,
        "user_id": userID,
      ])
  }
}
