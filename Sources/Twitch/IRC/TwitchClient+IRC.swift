import Foundation
import TwitchIRC

#if canImport(Combine)
  import Combine
#endif

extension TwitchClient {
  public func ircClient<Connection: IRCConnectionProtocol>(
    with options: TwitchIRCClient<Connection>.Options = .init(),
    connectionFactory: @escaping Connection.Factory
  ) async throws -> TwitchIRCClient<Connection> {
    return try await TwitchIRCClient(
      .authenticated(self.authentication),
      options: options,
      urlSession: self.urlSession,
      connectionFactory: connectionFactory
    )
  }

  public func ircClient(
    with options: TwitchIRCClient<IRCConnection>.Options = .init()
  ) async throws -> TwitchIRCClient<IRCConnection> {
    return try await TwitchIRCClient(
      .authenticated(self.authentication),
      options: options,
      urlSession: self.urlSession,
      connectionFactory: IRCConnection.init
    )
  }
}
