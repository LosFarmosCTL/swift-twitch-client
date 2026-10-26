extension EventSubSubscription {
  public static func autoModMessageHold(
    broadcasterID: String,
    moderatorID: String,
    version: String = "2"
  ) -> EventSubSubscription<AutoModMessageHoldEvent> {
    .init(
      type: EventType.autoModMessageHold.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID,
        "moderator_user_id": moderatorID,
      ])
  }

  public static func autoModMessageUpdate(
    broadcasterID: String,
    moderatorID: String,
    version: String = "2"
  ) -> EventSubSubscription<AutoModMessageUpdateEvent> {
    .init(
      type: EventType.autoModMessageUpdate.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID,
        "moderator_user_id": moderatorID,
      ])
  }

  public static func autoModSettingsUpdate(
    broadcasterID: String,
    moderatorID: String,
    version: String = "1"
  ) -> EventSubSubscription<AutoModSettingsUpdateEvent> {
    .init(
      type: EventType.autoModSettingsUpdate.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID,
        "moderator_user_id": moderatorID,
      ])
  }

  public static func autoModTermsUpdate(
    broadcasterID: String,
    moderatorID: String,
    version: String = "1"
  ) -> EventSubSubscription<AutoModTermsUpdateEvent> {
    .init(
      type: EventType.autoModTermsUpdate.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID,
        "moderator_user_id": moderatorID,
      ])
  }
}
