extension EventSubSubscription {
  public static func streamOnline(broadcasterID: String, version: String = "1")
    -> EventSubSubscription<StreamOnlineEvent>
  {
    .init(
      type: EventType.streamOnline.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }

  public static func streamOffline(broadcasterID: String, version: String = "1")
    -> EventSubSubscription<StreamOfflineEvent>
  {
    .init(
      type: EventType.streamOffline.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }
}
