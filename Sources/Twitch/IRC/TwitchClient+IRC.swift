import Foundation
import TwitchIRC

#if canImport(Combine)
  import Combine
#endif

extension TwitchClient {
  public func ircClient(
    with options: TwitchIRCClient.Options = .init()
  ) async throws -> TwitchIRCClient {
    return try await TwitchIRCClient(
      .authenticated(self.authentication),
      options: options,
      urlSession: self.urlSession
    )
  }
}
