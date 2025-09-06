extension EventSubSubscription where EventNotification == AutomodMessageHoldEvent {
  public static func automodMessageHold(
    broadcasterID: UserID, moderatorID: UserID, version: String = "2"
  ) -> Self {
    .init(
      type: EventType.automodMessageHold.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID,
        "moderator_user_id": moderatorID,
      ])
  }
}

extension EventSubSubscription where EventNotification == AutomodMessageUpdateEvent {
  public static func automodMessageUpdate(
    broadcasterID: UserID, moderatorID: UserID, version: String = "2"
  ) -> Self {
    .init(
      type: EventType.automodMessageUpdate.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID,
        "moderator_user_id": moderatorID,
      ])
  }
}

extension EventSubSubscription where EventNotification == AutomodSettingsUpdateEvent {
  public static func automodSettingsUpdate(
    broadcasterID: UserID, moderatorID: UserID, version: String = "1"
  ) -> Self {
    .init(
      type: EventType.automodSettingsUpdate.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID,
        "moderator_user_id": moderatorID,
      ])
  }
}

extension EventSubSubscription where EventNotification == AutomodTermsUpdateEvent {
  public static func automodTermsUpdate(
    broadcasterID: UserID, moderatorID: UserID, version: String = "1"
  ) -> Self {
    .init(
      type: EventType.automodTermsUpdate.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID,
        "moderator_user_id": moderatorID,
      ])
  }
}
