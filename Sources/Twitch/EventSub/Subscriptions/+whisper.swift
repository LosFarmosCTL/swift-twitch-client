extension EventSubSubscription {
  public static func userWhisperMessage(userID: String, version: String = "1")
    -> EventSubSubscription<UserWhisperMessageEvent>
  {
    .init(
      type: EventType.userWhisperMessage.rawValue, version: version,
      condition: [
        "user_id": userID
      ])
  }
}
