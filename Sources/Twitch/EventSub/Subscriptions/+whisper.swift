extension EventSubSubscription {
  public static func whisperReceived(userID: String, version: String = "1")
    -> EventSubSubscription<WhisperReceivedEvent>
  {
    .init(
      type: EventType.whisperReceived.rawValue, version: version,
      condition: [
        "user_id": userID
      ])
  }
}
