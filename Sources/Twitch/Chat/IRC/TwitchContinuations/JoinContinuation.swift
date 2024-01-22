import TwitchIRC

internal actor JoinContinuation: TwitchContinuation {
  private var continuation: CheckedContinuation<Void, Error>?
  private let channel: String

  internal func check(message: IncomingMessage) async -> Bool {
    return checkNotice(message: message) || checkJoin(message: message)
  }

  private func checkNotice(message: IncomingMessage) -> Bool {
    guard case .notice(let notice) = message else { return false }
    guard case .local(let channel, _, let noticeId) = notice.kind else {
      return false
    }

    guard channel == self.channel else { return false }

    switch noticeId {
    case .msgChannelSuspended:
      continuation?.resume(throwing: IRCError.channelSuspended(channel))
    case .msgBanned:
      continuation?.resume(throwing: IRCError.bannedFromChannel(channel))
    default: return false
    }

    continuation = nil
    return true
  }

  private func checkJoin(message: IncomingMessage) -> Bool {
    guard case .join(let join) = message else { return false }
    guard join.channel == self.channel else { return false }

    continuation?.resume()
    continuation = nil

    return true
  }

  internal init(
    _ continuation: CheckedContinuation<Void, Error>, channel: String
  ) {
    self.continuation = continuation
    self.channel = channel
  }
}
