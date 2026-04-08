import Foundation
import TwitchIRC

#if canImport(Combine)
  import Combine
#endif

extension TwitchClient {
  public func createIRCClient(
    with options: TwitchIRCClient.Options = .init()
  ) async throws -> TwitchIRCClient {
    return try await TwitchIRCClient(
      .authenticated(self.authentication),
      options: options,
      network: self.network
    )
  }
}
