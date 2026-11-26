extension EventSubSubscription {
  /// Creates a subscription description for channel chat clear notifications.
  ///
  /// Requires `user:read:chat`. With WebSockets, `userID` must match the token’s user.
  /// This subscription counts toward the user’s chat join limits if they have not joined the room.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/eventsub/reference/chat/#channel-chat-clear
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - userID: The Twitch user ID.
  public static func channelChatClear(
    broadcasterID: String, userID: String
  ) -> EventSubSubscription<ChannelChatClearEvent> {
    .init(
      type: "channel.chat.clear", version: "1",
      condition: [
        "broadcaster_user_id": broadcasterID,
        "user_id": userID,
      ])
  }

  /// Creates a subscription description for channel chat clear user messages
  /// notifications.
  ///
  /// Requires `user:read:chat`. With WebSockets, `userID` must match the token’s user.
  /// This subscription counts toward the user’s chat join limits if they have not joined the room.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/eventsub/reference/chat/#channel-chat-clear-user-messages
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - userID: The Twitch user ID.
  public static func channelChatClearUserMessages(
    broadcasterID: String, userID: String
  ) -> EventSubSubscription<ChannelChatClearUserMessagesEvent> {
    .init(
      type: "channel.chat.clear_user_messages", version: "1",
      condition: [
        "broadcaster_user_id": broadcasterID,
        "user_id": userID,
      ])
  }

  /// Creates a subscription description for channel chat message notifications.
  ///
  /// Requires `user:read:chat`. With WebSockets, `userID` must match the token’s user.
  /// This subscription counts toward the user’s chat join limits if they have not joined the room.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/eventsub/reference/chat/#channel-chat-message
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - userID: The Twitch user ID.
  public static func channelChatMessage(
    broadcasterID: String, userID: String
  ) -> EventSubSubscription<ChannelChatMessageEvent> {
    .init(
      type: "channel.chat.message", version: "1",
      condition: [
        "broadcaster_user_id": broadcasterID,
        "user_id": userID,
      ])
  }

  /// Creates a subscription description for channel chat message delete notifications.
  ///
  /// Requires `user:read:chat`. With WebSockets, `userID` must match the token’s user.
  /// This subscription counts toward the user’s chat join limits if they have not joined the room.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/eventsub/reference/chat/#channel-chat-message-delete
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - userID: The Twitch user ID.
  public static func channelChatMessageDelete(
    broadcasterID: String, userID: String
  ) -> EventSubSubscription<ChannelChatMessageDeleteEvent> {
    .init(
      type: "channel.chat.message_delete", version: "1",
      condition: [
        "broadcaster_user_id": broadcasterID,
        "user_id": userID,
      ])
  }

  /// Creates a subscription description for channel chat notification notifications.
  ///
  /// Requires `user:read:chat`. With WebSockets, `userID` must match the token’s user.
  /// This subscription counts toward the user’s chat join limits if they have not joined the room.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/eventsub/reference/chat/#channel-chat-notification
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - userID: The Twitch user ID.
  public static func channelChatNotification(
    broadcasterID: String, userID: String
  ) -> EventSubSubscription<ChannelChatNotificationEvent> {
    .init(
      type: "channel.chat.notification", version: "1",
      condition: [
        "broadcaster_user_id": broadcasterID,
        "user_id": userID,
      ])
  }

  /// Creates a subscription description for channel chat settings update notifications.
  ///
  /// Requires `user:read:chat`. With WebSockets, `userID` must match the token’s user.
  /// This subscription counts toward the user’s chat join limits if they have not joined the room.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/eventsub/reference/chat/#channel-chat-settings-update
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - userID: The Twitch user ID.
  public static func channelChatSettingsUpdate(
    broadcasterID: String, userID: String
  ) -> EventSubSubscription<ChannelChatSettingsUpdateEvent> {
    .init(
      type: "channel.chat_settings.update", version: "1",
      condition: [
        "broadcaster_user_id": broadcasterID,
        "user_id": userID,
      ])
  }

  /// Creates a subscription description for channel chat user message hold notifications.
  ///
  /// Requires `user:read:chat`. With WebSockets, `userID` must match the token’s user.
  /// This subscription counts toward the user’s chat join limits if they have not joined the room.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/eventsub/reference/chat/#channel-chat-user-message-hold
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - userID: The Twitch user ID.
  public static func channelChatUserMessageHold(
    broadcasterID: String, userID: String
  ) -> EventSubSubscription<ChannelChatUserMessageHoldEvent> {
    .init(
      type: "channel.chat.user_message_hold", version: "1",
      condition: [
        "broadcaster_user_id": broadcasterID,
        "user_id": userID,
      ])
  }

  /// Creates a subscription description for channel chat user message update
  /// notifications.
  ///
  /// Requires `user:read:chat`. With WebSockets, `userID` must match the token’s user.
  /// This subscription counts toward the user’s chat join limits if they have not joined the room.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/eventsub/reference/chat/#channel-chat-user-message-update
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - userID: The Twitch user ID.
  public static func channelChatUserMessageUpdate(
    broadcasterID: String, userID: String
  ) -> EventSubSubscription<ChannelChatUserMessageUpdateEvent> {
    .init(
      type: "channel.chat.user_message_update", version: "1",
      condition: [
        "broadcaster_user_id": broadcasterID,
        "user_id": userID,
      ])
  }
}
