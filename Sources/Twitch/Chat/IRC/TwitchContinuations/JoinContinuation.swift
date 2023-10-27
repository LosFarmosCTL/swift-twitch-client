import TwitchIRC

internal actor JoinContinuation: TwitchContinuation {
  private var continuation: CheckedContinuation<Void, Error>?
  private let channel: String

  internal func check(message: IncomingMessage) async {
    if case .join(let join) = message {
      if join.channel == self.channel {
        continuation?.resume()
        continuation = nil
      }
    } else if case .notice(let notice) = message {
      if case .local(let channel, _, let noticeId) = notice.kind {
        if case .msgChannelSuspended = noticeId {
          if channel == self.channel {
            continuation?.resume(throwing: IRCError.channelSuspended(channel))
            continuation = nil
          }
        } else if case .msgBanned = noticeId {
          if channel == self.channel {
            continuation?.resume(throwing: IRCError.bannedFromChannel(channel))
            continuation = nil
          }
        }
      }
    }
  }

  internal init(
    _ continuation: CheckedContinuation<Void, Error>, channel: String
  ) {
    self.continuation = continuation
    self.channel = channel
  }
}
