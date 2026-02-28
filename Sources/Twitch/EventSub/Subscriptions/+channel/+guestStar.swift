extension EventSubSubscription {
  public static func channelGuestStarSessionBegin(
    broadcasterID: String, moderatorID: String, version: String = "beta"
  ) -> EventSubSubscription<ChannelGuestStarSessionBeginEvent> {
    .init(
      type: EventType.channelGuestStarSessionBegin.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID,
        "moderator_user_id": moderatorID,
      ])
  }

  public static func channelGuestStarSessionEnd(
    broadcasterID: String, moderatorID: String, version: String = "beta"
  ) -> EventSubSubscription<ChannelGuestStarSessionEndEvent> {
    .init(
      type: EventType.channelGuestStarSessionEnd.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID,
        "moderator_user_id": moderatorID,
      ])
  }

  public static func channelGuestStarGuestUpdate(
    broadcasterID: String, moderatorID: String, version: String = "beta"
  ) -> EventSubSubscription<ChannelGuestStarGuestUpdateEvent> {
    .init(
      type: EventType.channelGuestStarGuestUpdate.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID,
        "moderator_user_id": moderatorID,
      ])
  }

  public static func channelGuestStarSettingsUpdate(
    broadcasterID: String, moderatorID: String, version: String = "beta"
  ) -> EventSubSubscription<ChannelGuestStarSettingsUpdateEvent> {
    .init(
      type: EventType.channelGuestStarSettingsUpdate.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID,
        "moderator_user_id": moderatorID,
      ])
  }
}
