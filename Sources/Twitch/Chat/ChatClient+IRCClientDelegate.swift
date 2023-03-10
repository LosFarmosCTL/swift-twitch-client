extension ChatClient: IRCClientDelegate {
  internal func didReceiveMessage(_ message: IRCMessage) {
    switch message {
    case let clearchat as CLEARCHAT: receivedClearchat(clearchat)
    case let clearmsg as CLEARMSG: receivedClearmsg(clearmsg)
    case let notice as NOTICE: receivedNotice(notice)
    case let privmsg as PRIVMSG: receivedPrivmsg(privmsg)
    case let roomstate as ROOMSTATE: receivedRoomstate(roomstate)
    case let usernotice as USERNOTICE: receivedUsernotice(usernotice)
    case let userstate as USERSTATE: receivedUserstate(userstate)
    case let whisper as WHISPER: receivedWhisper(whisper)
    default: break
    }
  }

  private func receivedClearchat(_ message: CLEARCHAT) {
    let timeoutOrBan = TimeoutOrBan(from: message)

    self.listener.forEach {
      if case let .timeoutOrBan(callback) = $0 { callback(timeoutOrBan) }
    }
  }

  private func receivedClearmsg(_ message: CLEARMSG) {
    let deletedMessage = DeletedMessage(from: message)

    self.listener.forEach {
      if case let .deletedMessage(callback) = $0 { callback(deletedMessage) }
    }
  }

  private func receivedNotice(_ message: NOTICE) {
    self.listener.forEach {
      if case let .NOTICE(callback) = $0 { callback(message) }
    }
  }

  private func receivedPrivmsg(_ message: PRIVMSG) {
    let chatMessage = ChatMessage(from: message)

    self.listener.forEach {
      if case let .message(callback) = $0 { callback(chatMessage) }
    }
  }

  private func receivedRoomstate(_ message: ROOMSTATE) {
    self.listener.forEach {
      if case let .ROOMSTATE(callback) = $0 { callback(message) }
    }
  }

  private func receivedUsernotice(_ message: USERNOTICE) {
    switch message.msgId {
    case "sub", "resub", "standardpayforward", "subgift":
      let sub = Sub(from: message)

      self.listener.forEach {
        if case let .sub(callback) = $0 { callback(sub) }
      }
    case "raid":
      let raid = Raid(from: message)

      self.listener.forEach {
        if case let .raid(callback) = $0 { callback(raid) }
      }
    case "announcement":
      let announcement = Announcement(from: message)

      self.listener.forEach {
        if case let .announcement(callback) = $0 { callback(announcement) }
      }
    default: return
    }
  }

  private func receivedUserstate(_ message: USERSTATE) {
    let userstate = Userstate(from: message)

    self.listener.forEach {
      if case let .userstate(callback) = $0 { callback(userstate) }
    }
  }

  private func receivedWhisper(_ message: WHISPER) {
    let whisper = Whisper(from: message)

    self.listener.forEach {
      if case let .whisper(callback) = $0 { callback(whisper) }
    }
  }
}
