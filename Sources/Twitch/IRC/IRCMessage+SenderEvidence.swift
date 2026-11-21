import Foundation

internal struct IRCChannelNotice {
  let login: String
  let text: String
  let code: String?
  let targetUserID: String?
  let timestamp: Date?
}

extension IRCMessage {
  var channelUserState: (login: String, privilege: ChatPrivilege)? {
    guard case .userState(let state) = message,
      !state.parsingLeftovers.unavailableKeys.contains("badges")
    else { return nil }
    return (
      IRCWireMessage.channelLogin(state.channel),
      ChatPrivilege(badgeIDs: state.badges.map(\.setID))
    )
  }

  var channelNotice: IRCChannelNotice? {
    guard case .notice(let notice) = message else { return nil }
    switch notice.kind {
    case .local(let channel, let text, _), .unknownLocal(let channel, let text, _):
      return IRCChannelNotice(
        login: IRCWireMessage.channelLogin(channel), text: text, code: notice.rawCode,
        targetUserID: notice.targetUserID, timestamp: chatIRCTimestamp(notice.timestampMilliseconds)
      )
    default: return nil
    }
  }
}

extension ChatPrivilege {
  init(badgeIDs: [String]) {
    let ids = Set(badgeIDs)
    self.init(
      isBroadcaster: ids.contains("broadcaster"),
      isModerator: ids.contains("moderator") || ids.contains("lead_moderator"),
      isVIP: ids.contains("vip"))
  }
}
