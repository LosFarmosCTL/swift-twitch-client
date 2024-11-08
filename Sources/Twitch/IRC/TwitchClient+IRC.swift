import Foundation
import TwitchIRC

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

#if canImport(Combine)
  import Combine
#endif

extension TwitchClient {
  public func ircClient<WebsocketProvider: WebsocketTaskProvider>(
    with options: TwitchIRCClient<WebsocketProvider>.Options = .init(),
    websocketProvider: WebsocketProvider
  ) async throws -> TwitchIRCClient<WebsocketProvider> {
    return try await TwitchIRCClient(
      .authenticated(self.authentication),
      options: options,
      websocketProvider: websocketProvider
    )
  }

  public func ircClient(
    with options: TwitchIRCClient<URLSession>.Options = .init()
  ) async throws -> TwitchIRCClient<URLSession> {
    return try await ircClient(with: options, websocketProvider: self.urlSession)
  }
}
