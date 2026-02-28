extension EventSubSubscription {
  public static func channelModerate(
    broadcasterID: String, moderatorID: String, version: String = "2"
  ) -> EventSubSubscription<ChannelModerateEvent> {
    .init(
      type: EventType.channelModerate.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID,
        "moderator_user_id": moderatorID,
      ])
  }

  public static func channelBan(broadcasterID: String, version: String = "1")
    -> EventSubSubscription<ChannelBanEvent>
  {
    .init(
      type: EventType.channelBan.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }

  public static func channelUnban(broadcasterID: String, version: String = "1")
    -> EventSubSubscription<ChannelUnbanEvent>
  {
    .init(
      type: EventType.channelUnban.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }

  public static func channelModeratorAdd(broadcasterID: String, version: String = "1")
    -> EventSubSubscription<ChannelModeratorAddEvent>
  {
    .init(
      type: EventType.channelModeratorAdd.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }

  public static func channelModeratorRemove(broadcasterID: String, version: String = "1")
    -> EventSubSubscription<ChannelModeratorRemoveEvent>
  {
    .init(
      type: EventType.channelModeratorRemove.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }

  public static func channelUnbanRequestCreate(
    broadcasterID: String, moderatorID: String, version: String = "1"
  ) -> EventSubSubscription<ChannelUnbanRequestCreateEvent> {
    .init(
      type: EventType.channelUnbanRequestCreate.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID,
        "moderator_user_id": moderatorID,
      ])
  }

  public static func channelUnbanRequestResolve(
    broadcasterID: String, moderatorID: String, version: String = "1"
  ) -> EventSubSubscription<ChannelUnbanRequestResolveEvent> {
    .init(
      type: EventType.channelUnbanRequestResolve.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID,
        "moderator_user_id": moderatorID,
      ])
  }

  public static func channelWarningAcknowledge(
    broadcasterID: String, moderatorID: String, version: String = "1"
  ) -> EventSubSubscription<ChannelWarningAcknowledgeEvent> {
    .init(
      type: EventType.channelWarningAcknowledge.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID,
        "moderator_user_id": moderatorID,
      ])
  }

  public static func channelWarningSend(
    broadcasterID: String, moderatorID: String, version: String = "1"
  ) -> EventSubSubscription<ChannelWarningSendEvent> {
    .init(
      type: EventType.channelWarningSend.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID,
        "moderator_user_id": moderatorID,
      ])
  }

  public static func channelSuspiciousUserMessage(
    broadcasterID: String, moderatorID: String, version: String = "1"
  ) -> EventSubSubscription<ChannelSuspiciousUserMessageEvent> {
    .init(
      type: EventType.channelSuspiciousUserMessage.rawValue, version: version,
      condition: [
        "moderator_user_id": moderatorID,
        "broadcaster_user_id": broadcasterID,
      ])
  }

  public static func channelSuspiciousUserUpdate(
    broadcasterID: String, moderatorID: String, version: String = "1"
  ) -> EventSubSubscription<ChannelSuspiciousUserUpdateEvent> {
    .init(
      type: EventType.channelSuspiciousUserUpdate.rawValue, version: version,
      condition: [
        "moderator_user_id": moderatorID,
        "broadcaster_user_id": broadcasterID,
      ])
  }

  public static func channelShieldModeBegin(
    broadcasterID: String, moderatorID: String, version: String = "1"
  ) -> EventSubSubscription<ChannelShieldModeBeginEvent> {
    .init(
      type: EventType.channelShieldModeBegin.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID,
        "moderator_user_id": moderatorID,
      ])
  }

  public static func channelShieldModeEnd(
    broadcasterID: String, moderatorID: String, version: String = "1"
  ) -> EventSubSubscription<ChannelShieldModeEndEvent> {
    .init(
      type: EventType.channelShieldModeEnd.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID,
        "moderator_user_id": moderatorID,
      ])
  }
}
