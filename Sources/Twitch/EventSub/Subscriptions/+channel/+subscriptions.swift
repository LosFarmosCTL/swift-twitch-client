extension EventSubSubscription {
  public static func channelSubscribe(broadcasterID: String, version: String = "1")
    -> EventSubSubscription<ChannelSubscribeEvent>
  {
    .init(
      type: EventType.channelSubscribe.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }

  public static func channelSubscriptionEnd(broadcasterID: String, version: String = "1")
    -> EventSubSubscription<ChannelSubscriptionEndEvent>
  {
    .init(
      type: EventType.channelSubscriptionEnd.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }

  public static func channelSubscriptionGift(broadcasterID: String, version: String = "1")
    -> EventSubSubscription<ChannelSubscriptionGiftEvent>
  {
    .init(
      type: EventType.channelSubscriptionGift.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }

  public static func channelSubscriptionMessage(
    broadcasterID: String, version: String = "1"
  ) -> EventSubSubscription<ChannelSubscriptionMessageEvent> {
    .init(
      type: EventType.channelSubscriptionMessage.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }
}
