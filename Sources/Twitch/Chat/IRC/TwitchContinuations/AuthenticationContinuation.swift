import TwitchIRC

internal actor AuthenticationContinuation: TwitchContinuation {
  private var continuation: CheckedContinuation<Void, Error>?

  internal func check(message: IncomingMessage) async {
    if case .connectionNotice = message {
      continuation?.resume()
      continuation = nil
    } else if case .notice(let notice) = message {
      if case .global(let message) = notice.kind {
        if message.contains("Login authentication failed") {
          continuation?.resume(throwing: IRCError.loginFailed)
          continuation = nil
        }
      }
    }
  }

  internal init(_ continuation: CheckedContinuation<Void, Error>) {
    self.continuation = continuation
  }
}
