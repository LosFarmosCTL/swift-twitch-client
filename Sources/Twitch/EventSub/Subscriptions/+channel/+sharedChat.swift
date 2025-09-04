extension EventSubSubscription
where EventNotification == ChannelSharedChatSessionBeginEvent {
  public static func channelSharedChatSessionBegin(
    broadcasterID: UserID, version: String = "1"
  ) -> Self {
    .init(
      type: EventType.channelSharedChatSessionBegin.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }
}

extension EventSubSubscription
where EventNotification == ChannelSharedChatSessionUpdateEvent {
  public static func channelSharedChatSessionUpdate(
    broadcasterID: UserID, version: String = "1"
  ) -> Self {
    .init(
      type: EventType.channelSharedChatSessionUpdate.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }
}

extension EventSubSubscription
where EventNotification == ChannelSharedChatSessionEndEvent {
  public static func channelSharedChatSessionEnd(
    broadcasterID: UserID, version: String = "1"
  ) -> Self {
    .init(
      type: EventType.channelSharedChatSessionEnd.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }
}
