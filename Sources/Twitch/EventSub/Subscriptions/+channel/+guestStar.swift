extension EventSubSubscription
where EventNotification == ChannelGuestStarSessionBeginEvent {
  public static func channelGuestStarSessionBegin(
    broadcasterID: UserID, moderatorID: UserID, version: String = "beta"
  ) -> Self {
    .init(
      type: EventType.channelGuestStarSessionBegin.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID,
        "moderator_user_id": moderatorID,
      ])
  }
}

extension EventSubSubscription
where EventNotification == ChannelGuestStarSessionEndEvent {
  public static func channelGuestStarSessionEnd(
    broadcasterID: UserID, moderatorID: UserID, version: String = "beta"
  ) -> Self {
    .init(
      type: EventType.channelGuestStarSessionEnd.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID,
        "moderator_user_id": moderatorID,
      ])
  }
}

extension EventSubSubscription
where EventNotification == ChannelGuestStarGuestUpdateEvent {
  public static func channelGuestStarGuestUpdate(
    broadcasterID: UserID, moderatorID: UserID, version: String = "beta"
  ) -> Self {
    .init(
      type: EventType.channelGuestStarGuestUpdate.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID,
        "moderator_user_id": moderatorID,
      ])
  }
}

extension EventSubSubscription
where EventNotification == ChannelGuestStarSettingsUpdateEvent {
  public static func channelGuestStarSettingsUpdate(
    broadcasterID: UserID, moderatorID: UserID, version: String = "beta"
  ) -> Self {
    .init(
      type: EventType.channelGuestStarSettingsUpdate.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID,
        "moderator_user_id": moderatorID,
      ])
  }
}
