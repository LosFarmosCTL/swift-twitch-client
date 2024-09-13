import Foundation
import TwitchIRC

#if canImport(Combine)
  import Combine
#endif

extension TwitchClient {
  public func ircClient() async throws -> TwitchIRCClient {
    return try await TwitchIRCClient(
      .authenticated(self.authentication),
      urlSession: self.urlSession
    )
  }
}
