import TwitchIRC

internal actor AuthenticationContinuation: TwitchContinuation {
  private var continuation: CheckedContinuation<Void, Error>?

  internal func check(message: IncomingMessage) async -> Bool {
    return checkConnectionNotice(message: message)
      || checkNotice(message: message)
  }

  private func checkConnectionNotice(message: IncomingMessage) -> Bool {
    guard case .connectionNotice = message else { return false }

    continuation?.resume()
    continuation = nil
    return true
  }

  private func checkNotice(message: IncomingMessage) -> Bool {
    guard case .notice(let notice) = message else { return false }
    guard case .global(let message) = notice.kind else { return false }

    guard message.contains("Login authentication failed") else { return false }

    continuation?.resume(throwing: IRCError.loginFailed)
    continuation = nil
    return true
  }

  internal func cancel(error: IRCError) {
    continuation?.resume(throwing: error)
    continuation = nil
  }

  internal func setContinuation(
    _ continuation: CheckedContinuation<Void, Error>
  ) { self.continuation = continuation }
}
