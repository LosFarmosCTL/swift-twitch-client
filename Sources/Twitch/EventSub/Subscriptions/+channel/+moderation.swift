extension EventSubSubscription where EventNotification == ChannelModerateEvent {
  public static func channelModerate(
    broadcasterID: UserID, moderatorID: UserID, version: String = "2"
  ) -> Self {
    .init(
      type: EventType.channelModerate.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID,
        "moderator_user_id": moderatorID,
      ])
  }
}

extension EventSubSubscription where EventNotification == ChannelBanEvent {
  public static func channelBan(broadcasterID: UserID, version: String = "1") -> Self {
    .init(
      type: EventType.channelBan.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }
}

extension EventSubSubscription where EventNotification == ChannelUnbanEvent {
  public static func channelUnban(broadcasterID: UserID, version: String = "1") -> Self {
    .init(
      type: EventType.channelUnban.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }
}

extension EventSubSubscription where EventNotification == ChannelModeratorAddEvent {
  public static func channelModeratorAdd(broadcasterID: UserID, version: String = "1")
    -> Self
  {
    .init(
      type: EventType.channelModeratorAdd.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }
}

extension EventSubSubscription where EventNotification == ChannelModeratorRemoveEvent {
  public static func channelModeratorRemove(broadcasterID: UserID, version: String = "1")
    -> Self
  {
    .init(
      type: EventType.channelModeratorRemove.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }
}

extension EventSubSubscription where EventNotification == ChannelUnbanRequestCreateEvent {
  public static func channelUnbanRequestCreate(
    broadcasterID: UserID, moderatorID: UserID, version: String = "1"
  ) -> Self {
    .init(
      type: EventType.channelUnbanRequestCreate.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID,
        "moderator_user_id": moderatorID,
      ])
  }
}

extension EventSubSubscription
where EventNotification == ChannelUnbanRequestResolveEvent {
  public static func channelUnbanRequestResolve(
    broadcasterID: UserID, moderatorID: UserID, version: String = "1"
  ) -> Self {
    .init(
      type: EventType.channelUnbanRequestResolve.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID,
        "moderator_user_id": moderatorID,
      ])
  }
}

extension EventSubSubscription where EventNotification == ChannelWarningAcknowledgeEvent {
  public static func channelWarningAcknowledge(
    broadcasterID: UserID, moderatorID: UserID, version: String = "1"
  ) -> Self {
    .init(
      type: EventType.channelWarningAcknowledge.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID,
        "moderator_user_id": moderatorID,
      ])
  }
}

extension EventSubSubscription where EventNotification == ChannelWarningSendEvent {
  public static func channelWarningSend(
    broadcasterID: UserID, moderatorID: UserID, version: String = "1"
  ) -> Self {
    .init(
      type: EventType.channelWarningSend.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID,
        "moderator_user_id": moderatorID,
      ])
  }
}

extension EventSubSubscription
where EventNotification == ChannelSuspiciousUserMessageEvent {
  public static func channelSuspiciousUserMessage(
    broadcasterID: UserID, moderatorID: UserID, version: String = "1"
  ) -> Self {
    .init(
      type: EventType.channelSuspiciousUserMessage.rawValue, version: version,
      condition: [
        "moderator_user_id": moderatorID,
        "broadcaster_user_id": broadcasterID,
      ])
  }
}

extension EventSubSubscription
where EventNotification == ChannelSuspiciousUserUpdateEvent {
  public static func channelSuspiciousUserUpdate(
    broadcasterID: UserID, moderatorID: UserID, version: String = "1"
  ) -> Self {
    .init(
      type: EventType.channelSuspiciousUserUpdate.rawValue, version: version,
      condition: [
        "moderator_user_id": moderatorID,
        "broadcaster_user_id": broadcasterID,
      ])
  }
}

extension EventSubSubscription where EventNotification == ChannelShieldModeBeginEvent {
  public static func channelShieldModeBegin(
    broadcasterID: UserID, moderatorID: UserID, version: String = "1"
  ) -> Self {
    .init(
      type: EventType.channelShieldModeBegin.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID,
        "moderator_user_id": moderatorID,
      ])
  }
}

extension EventSubSubscription where EventNotification == ChannelShieldModeEndEvent {
  public static func channelShieldModeEnd(
    broadcasterID: UserID, moderatorID: UserID, version: String = "1"
  ) -> Self {
    .init(
      type: EventType.channelShieldModeEnd.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID,
        "moderator_user_id": moderatorID,
      ])
  }
}
