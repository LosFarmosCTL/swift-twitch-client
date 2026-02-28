extension EventSubSubscription {
  public static func userUpdate(userID: String, version: String = "1")
    -> EventSubSubscription<UserUpdateEvent>
  {
    .init(
      type: EventType.userUpdate.rawValue, version: version,
      condition: [
        "user_id": userID
      ])
  }
}
