import TwitchIRC

internal actor PartContinuation: TwitchContinuation {
  private var continuation: CheckedContinuation<Void, Error>?
  private let channel: String

  internal func check(message: IncomingMessage) async {
    guard case .part(let part) = message else { return }
    guard part.channel == self.channel else { return }

    continuation?.resume()
    continuation = nil
  }

  internal init(
    _ continuation: CheckedContinuation<Void, Error>, channel: String
  ) {
    self.continuation = continuation
    self.channel = channel
  }
}
