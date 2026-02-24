extension EventSubSubscription where EventNotification == UserUpdateEvent {
  public static func userUpdate(userID: String, version: String = "1") -> Self {
    .init(
      type: EventType.userUpdate.rawValue, version: version,
      condition: [
        "user_id": userID
      ])
  }
}
