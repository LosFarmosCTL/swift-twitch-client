import Foundation
import NIO
import Twitch
import TwitchIRC

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

public struct AsyncWebsocketProvider: WebsocketTaskProvider {
  public typealias Task = AsyncWebsocket

  internal static let shared: AsyncWebsocketProvider = .init()
  private init() {}

  public func task(with: URL) -> Task {
    AsyncWebsocket(url: with, eventLoopGroup: MultiThreadedEventLoopGroup(numberOfThreads: 1))
  }
}

public typealias WebsocketKitIRCConnection = IRCConnection<AsyncWebsocketProvider>

extension TwitchIRCClient where WebsocketProvider == AsyncWebsocketProvider {
  public init(
      _ authenticationStyle: AuthenticationStyle,
      options: Options = .init()
  ) async throws {
    try await self.init(authenticationStyle, options: options, websocketProvider: .shared)
  }
}

extension TwitchClient {
  public func ircClient(
    with options: TwitchIRCClient<AsyncWebsocketProvider>.Options = .init()
  ) async throws -> TwitchIRCClient<AsyncWebsocketProvider> {
    return try await TwitchIRCClient(
      .authenticated(self.authentication),
      options: options,
      websocketProvider: .shared
    )
  }
}
