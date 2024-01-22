import TwitchIRC

internal actor CapabilitiesContinuation: TwitchContinuation {
  private var continuation: CheckedContinuation<Void, Error>?

  internal func check(message: IncomingMessage) async -> Bool {
    guard case .capabilities = message else { return false }

    continuation?.resume()
    continuation = nil

    return true
  }

  internal init(_ continuation: CheckedContinuation<Void, Error>) {
    self.continuation = continuation
  }
}
