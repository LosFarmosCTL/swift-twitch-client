import Foundation
import TwitchIRC

extension ManagedChat {
  func emitChatIRCMessage(_ message: IncomingMessage, role: IRCRecovery.Role) {
    let event = IRCMessage(role: role, message: message)
    receiveChatIRC(event)
    ircObservers.yield(event)
    #if canImport(Combine)
      ircPublishers.yield(event)
    #endif
  }

  private func receiveChatIRC(_ event: IRCMessage) {
    let message = event.message
    let writer = event.role == .write
    let authenticatesSender = writer || configuration.reader == .irc(.authenticated)

    if let evidence = event.channelUserState, authenticatesSender {
      if let channel = knownChannels[.login(evidence.login)] {
        observeChatPrivilege(evidence.privilege, in: channel.id)
        publishChatState()
      } else if writer {
        senderEvidence[.login(evidence.login), default: SenderEvidence()].observedPrivilege =
          evidence.privilege
      }
      return
    }

    if let notice = event.channelNotice {
      receiveChatIRCNotice(notice, role: event.role, authenticatesSender: authenticatesSender)
      return
    }

    guard !writer, let login = message.chatChannel,
      let channel = knownChannels[.init(login: login)],
      let member = memberships[channel.id]
    else { return }

    receiveChatIRCReaderMessage(message, for: member)
  }

  private func receiveChatIRCReaderMessage(_ message: IncomingMessage, for member: Membership) {
    let channel = member.channel
    let payload: ChatEvent.Payload
    var stateChanged = false
    let timestamp = message.chatTimestamp
    let receivedAt = Date()

    switch message {
    case .privateMessage(let value):
      let chatMessage = ChatMessage(irc: value)
      stateChanged = observeSenderBadges(
        userID: value.userID,
        isSourceChannel: value.source == nil || value.source?.roomID == channel.id,
        hasBadges: !value.parsingLeftovers.unavailableKeys.contains("badges"),
        in: channel.id, badgeIDs: chatMessage.badges.map(\.setID))
      payload = .message(chatMessage)
    case .userNotice(let value):
      stateChanged = observeSenderBadges(
        userID: value.userID,
        isSourceChannel: value.source == nil || value.source?.roomID == channel.id,
        hasBadges: !value.parsingLeftovers.unavailableKeys.contains("badges"),
        in: channel.id, badgeIDs: value.badges.map(\.setID))
      payload = .notification(ChatNotification(irc: value))
    case .roomState(let value):
      receiveChatIRCSettings(value, for: member)
      return
    case .clearMessage(let value):
      emitChatDeletion(
        ChatMessageDeletion(
          messageID: value.targetMessageID,
          author: ChatUser(id: nil, login: value.userLogin.chatNonempty, displayName: nil),
          text: value.message, moderator: nil), channel: channel, timestamp: timestamp,
        receivedAt: receivedAt)
      return
    case .clearChat(let value):
      receiveChatIRCClear(value, channel: channel, timestamp: timestamp, receivedAt: receivedAt)
      return
    default: return
    }

    emitChat(
      ChatEvent(channel: channel, timestamp: timestamp, receivedAt: receivedAt, payload: payload))
    if stateChanged { publishChatState() }
  }

  private func receiveChatIRCClear(
    _ value: ClearChat, channel: ChatChannel, timestamp: Date?, receivedAt: Date
  ) {
    let user = value.userLogin.map {
      ChatUser(id: value.targetUserID, login: $0, displayName: nil)
    }

    if let user {
      let action: ChatModeration.Action
      if let seconds = value.banDuration {
        let until = (timestamp ?? receivedAt).addingTimeInterval(Double(seconds))
        action = .timeout(
          user: user, until: until, duration: .seconds(seconds), reason: nil)
      } else {
        action = .ban(user: user, reason: nil)
      }

      acceptChatModeration(
        ChatModeration(moderator: nil, sourceChannelID: nil, action: action),
        channel: channel, timestamp: timestamp, receivedAt: receivedAt)
    }
    emitChat(
      ChatEvent(
        channel: channel, timestamp: timestamp, receivedAt: receivedAt,
        payload: .messagesCleared(user: user)))
  }

  private func receiveChatIRCNotice(
    _ notice: IRCChannelNotice, role: IRCRecovery.Role, authenticatesSender: Bool
  ) {
    let directedAtSender =
      authenticatesSender
      && (notice.targetUserID == nil || notice.targetUserID == credentials?.userID)
    guard let channel = knownChannels[.login(notice.login)] else {
      if role == .write, directedAtSender, notice.code == "msg_banned" {
        senderEvidence[.login(notice.login), default: SenderEvidence()].restriction = .banned
      }
      return
    }

    if directedAtSender, notice.code == "msg_banned" {
      senderEvidence[.id(channel.id), default: SenderEvidence()].restriction = .banned
      sendDestinations.insert(channel.id)
    }

    emitChat(
      ChatEvent(
        channel: channel, timestamp: notice.timestamp,
        payload: .notice(code: notice.code, message: notice.text)))
    publishChatState()
  }
}
