extension EventSubSubscription where EventNotification == WhisperReceivedEvent {
  public static func whisperReceived(userID: UserID, version: String = "1") -> Self {
    .init(
      type: EventType.whisperReceived.rawValue, version: version,
      condition: [
        "user_id": userID
      ])
  }
}
