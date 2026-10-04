import TwitchIRC

@testable import Twitch

extension IRCConnectionPool {
  func connect() async throws -> AsyncThrowingStream<IncomingMessage, Error> {
    let stream = try start()
    try await waitUntilConnected()
    return stream
  }
}
