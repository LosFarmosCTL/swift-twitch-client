import Foundation
import NIO
import Twitch
import TwitchIRC

public struct WebsocketKitTaskProvider: WebsocketTaskProvider {
  public typealias Task = WebsocketKitTask

  internal static let shared: WebsocketKitTaskProvider = .init()
  private init() {}

  public func task(with: URL) -> Task {
    WebsocketKitTask(
      url: with, eventLoopGroup: MultiThreadedEventLoopGroup(numberOfThreads: 1))
  }
}

extension TwitchIRCClient where WebsocketProvider == WebsocketKitTaskProvider {
  public init(
    _ authenticationStyle: AuthenticationStyle,
    options: Options = .init()
  ) async throws {
    try await self.init(authenticationStyle, options: options, websocketProvider: .shared)
  }
}

extension TwitchClient {
  public func ircClient(
    with options: TwitchIRCClient<WebsocketKitTaskProvider>.Options = .init()
  ) async throws -> TwitchIRCClient<WebsocketKitTaskProvider> {
    return try await TwitchIRCClient(
      .authenticated(self.authentication),
      options: options,
      websocketProvider: .shared
    )
  }
}
