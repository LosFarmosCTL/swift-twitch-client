import Foundation
import TwitchIRC

internal enum ChatIRCSetting: CaseIterable, Hashable {
  case emoteOnly
  case subscribersOnly
  case uniqueMessages
  case followersOnly
  case slowMode
}

extension ManagedChat {
  func receiveEventSubSettings(
    _ event: ChannelChatSettingsUpdateEvent, in channel: ChatChannel, timestamp: Date?
  ) {
    let settings = ChatRoomSettings(eventSub: event)
    memberships[channel.id]?.settings = settings
    emitChat(ChatEvent(channel: channel, timestamp: timestamp, payload: .settingsChanged(settings)))
    publishChatState()
  }

  func receiveChatIRCSettings(_ value: RoomState, for member: Membership) {
    var settings = member.settings
    var supplied = member.roomSettingFields

    if let value = value.emoteOnly {
      settings.emoteOnly = value
      supplied.insert(.emoteOnly)
    }
    if let value = value.subsOnly {
      settings.subscribersOnly = value
      supplied.insert(.subscribersOnly)
    }
    if let value = value.r9k {
      settings.uniqueMessages = value
      supplied.insert(.uniqueMessages)
    }
    if let value = value.slow {
      settings.slowMode = value > 0 ? .seconds(value) : nil
      supplied.insert(.slowMode)
    }
    if let value = value.followersOnly {
      settings.followersOnly = value >= 0 ? .seconds(value * 60) : nil
      supplied.insert(.followersOnly)
    }

    settings.isKnown = supplied.count == ChatIRCSetting.allCases.count
    member.roomSettingFields = supplied
    member.settings = settings
    emitChat(
      ChatEvent(channel: member.channel, timestamp: nil, payload: .settingsChanged(settings)))
    publishChatState()
  }

  func startChatSettingsSnapshot(for attempt: MembershipAttempt) {
    guard let member = memberships[attempt.channelID] else { return }
    member.settingsTask?.cancel()
    member.settingsTask = Task { [weak client, credentials, network, diagnostics] in
      let snapshot = try? await TwitchClient.helix(
        for: .getChatSettings(of: attempt.channelID),
        credentials: credentials,
        network: network,
        diagnostics: diagnostics
      )

      guard let snapshot, !Task.isCancelled else { return }

      await client?.withChat { $0.acceptChatSettingsSnapshot(snapshot.value, for: attempt) }
    }
  }

  private func acceptChatSettingsSnapshot(_ settings: ChatSettings, for attempt: MembershipAttempt)
  {
    guard isCurrent(attempt), let member = memberships[attempt.channelID], !member.settings.isKnown
    else { return }

    member.settings = ChatRoomSettings(
      emoteOnly: settings.emoteMode, subscribersOnly: settings.subscriberMode,
      uniqueMessages: settings.uniqueChatMode,
      followersOnly: settings.followerMode
        ? settings.followerModeDuration.map { .seconds($0 * 60) } : nil,
      slowMode: settings.slowMode ? settings.slowModeWaitTime.map { .seconds($0) } : nil,
      isKnown: true)
    publishChatState()
  }
}
