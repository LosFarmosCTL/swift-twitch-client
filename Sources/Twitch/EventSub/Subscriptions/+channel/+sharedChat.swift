extension EventSubSubscription {
  /// Creates a subscription description for channel shared chat session begin
  /// notifications.
  ///
  /// No event-specific scope is required.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/eventsub/reference/chat/#channel-shared-chat-begin
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///
  /// - Returns: A subscription that decodes `ChannelSharedChatSessionBeginEvent`
  ///   payloads.
  public static func channelSharedChatSessionBegin(
    broadcasterID: String
  ) -> EventSubSubscription<ChannelSharedChatSessionBeginEvent> {
    .init(
      type: "channel.shared_chat.begin", version: "1",
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }

  /// Creates a subscription description for channel shared chat session update
  /// notifications.
  ///
  /// No event-specific scope is required.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/eventsub/reference/chat/#channel-shared-chat-update
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///
  /// - Returns: A subscription that decodes `ChannelSharedChatSessionUpdateEvent`
  ///   payloads.
  public static func channelSharedChatSessionUpdate(
    broadcasterID: String
  ) -> EventSubSubscription<ChannelSharedChatSessionUpdateEvent> {
    .init(
      type: "channel.shared_chat.update", version: "1",
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }

  /// Creates a subscription description for channel shared chat session end
  /// notifications.
  ///
  /// No event-specific scope is required.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/eventsub/reference/chat/#channel-shared-chat-end
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  public static func channelSharedChatSessionEnd(
    broadcasterID: String
  ) -> EventSubSubscription<ChannelSharedChatSessionEndEvent> {
    .init(
      type: "channel.shared_chat.end", version: "1",
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }
}
