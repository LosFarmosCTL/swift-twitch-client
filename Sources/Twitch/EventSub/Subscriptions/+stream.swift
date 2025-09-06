extension EventSubSubscription where EventNotification == StreamOnlineEvent {
  public static func streamOnline(broadcasterID: UserID, version: String = "1") -> Self {
    .init(
      type: EventType.streamOnline.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }
}

extension EventSubSubscription where EventNotification == StreamOfflineEvent {
  public static func streamOffline(broadcasterID: UserID, version: String = "1") -> Self {
    .init(
      type: EventType.streamOffline.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }
}
