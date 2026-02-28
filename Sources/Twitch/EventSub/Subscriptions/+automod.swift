extension EventSubSubscription {
  public static func automodMessageHold(
    broadcasterID: String,
    moderatorID: String,
    version: String = "2"
  ) -> EventSubSubscription<AutomodMessageHoldEvent> {
    .init(
      type: EventType.automodMessageHold.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID,
        "moderator_user_id": moderatorID,
      ])
  }

  public static func automodMessageUpdate(
    broadcasterID: String,
    moderatorID: String,
    version: String = "2"
  ) -> EventSubSubscription<AutomodMessageUpdateEvent> {
    .init(
      type: EventType.automodMessageUpdate.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID,
        "moderator_user_id": moderatorID,
      ])
  }

  public static func automodSettingsUpdate(
    broadcasterID: String,
    moderatorID: String,
    version: String = "1"
  ) -> EventSubSubscription<AutomodSettingsUpdateEvent> {
    .init(
      type: EventType.automodSettingsUpdate.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID,
        "moderator_user_id": moderatorID,
      ])
  }

  public static func automodTermsUpdate(
    broadcasterID: String,
    moderatorID: String,
    version: String = "1"
  ) -> EventSubSubscription<AutomodTermsUpdateEvent> {
    .init(
      type: EventType.automodTermsUpdate.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID,
        "moderator_user_id": moderatorID,
      ])
  }
}
