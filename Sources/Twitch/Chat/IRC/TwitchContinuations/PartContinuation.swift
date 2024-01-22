import TwitchIRC

internal actor PartContinuation: TwitchContinuation {
  private var continuation: CheckedContinuation<Void, Error>?
  private let channel: String

  internal func check(message: IncomingMessage) async -> Bool {
    guard case .part(let part) = message else { return false }
    guard part.channel == self.channel else { return false }

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
