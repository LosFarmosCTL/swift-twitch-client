extension EventSubSubscription {
  /// Creates a subscription description for channel shared chat session begin
  /// notifications.
  ///
  /// No event-specific scope is required.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelshared_chatbegin
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - version: The EventSub subscription schema version. Defaults to `"1"`.
  ///
  /// - Returns: A subscription that decodes `ChannelSharedChatSessionBeginEvent`
  ///   payloads.
  public static func channelSharedChatSessionBegin(
    broadcasterID: String, version: String = "1"
  ) -> EventSubSubscription<ChannelSharedChatSessionBeginEvent> {
    .init(
      type: EventType.channelSharedChatSessionBegin.rawValue, version: version,
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
  /// https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelshared_chatupdate
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - version: The EventSub subscription schema version. Defaults to `"1"`.
  ///
  /// - Returns: A subscription that decodes `ChannelSharedChatSessionUpdateEvent`
  ///   payloads.
  public static func channelSharedChatSessionUpdate(
    broadcasterID: String, version: String = "1"
  ) -> EventSubSubscription<ChannelSharedChatSessionUpdateEvent> {
    .init(
      type: EventType.channelSharedChatSessionUpdate.rawValue, version: version,
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
  /// https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelshared_chatend
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - version: The EventSub subscription schema version. Defaults to `"1"`.
  public static func channelSharedChatSessionEnd(
    broadcasterID: String, version: String = "1"
  ) -> EventSubSubscription<ChannelSharedChatSessionEndEvent> {
    .init(
      type: EventType.channelSharedChatSessionEnd.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }
}
