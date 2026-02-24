extension EventSubSubscription where EventNotification == ChannelSubscribeEvent {
  public static func channelSubscribe(broadcasterID: String, version: String = "1")
    -> Self
  {
    .init(
      type: EventType.channelSubscribe.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }
}

extension EventSubSubscription where EventNotification == ChannelSubscriptionEndEvent {
  public static func channelSubscriptionEnd(broadcasterID: String, version: String = "1")
    -> Self
  {
    .init(
      type: EventType.channelSubscriptionEnd.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }
}

extension EventSubSubscription where EventNotification == ChannelSubscriptionGiftEvent {
  public static func channelSubscriptionGift(broadcasterID: String, version: String = "1")
    -> Self
  {
    .init(
      type: EventType.channelSubscriptionGift.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }
}

extension EventSubSubscription
where EventNotification == ChannelSubscriptionMessageEvent {
  public static func channelSubscriptionMessage(
    broadcasterID: String, version: String = "1"
  ) -> Self {
    .init(
      type: EventType.channelSubscriptionMessage.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }
}
