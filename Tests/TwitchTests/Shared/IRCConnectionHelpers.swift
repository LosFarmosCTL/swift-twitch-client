import TwitchIRC

@testable import Twitch

extension AsyncThrowingStream where Element == IRCConnectionUpdate, Failure == any Error {
  func nextState(where matches: (IRCState) -> Bool) async throws -> IRCState? {
    for try await update in self {
      if case .state(let state) = update, matches(state) { return state }
    }
    return nil
  }

  func nextMessage() async throws -> IncomingMessage? {
    for try await update in self {
      if case .message(let message) = update { return message }
    }
    return nil
  }
}
