import TwitchIRC

internal actor CapabilitiesContinuation: TwitchContinuation {
  private var continuation: CheckedContinuation<Void, Error>?

  internal func check(message: IncomingMessage) async {
    guard case .capabilities = message else { return }

    continuation?.resume()
    continuation = nil
  }

  internal init(_ continuation: CheckedContinuation<Void, Error>) {
    self.continuation = continuation
  }
}
